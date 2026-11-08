#!/usr/bin/env python3
"""Build the Swift packages and run the shared tests through an SPM consumer."""

import argparse
import json
import os
from pathlib import Path
import platform
import plistlib
import re
import shlex
import shutil
import subprocess
import tempfile


def run(command, log, *, cwd, env):
    print(shlex.join(command), flush=True)
    with log.open("w") as output:
        result = subprocess.run(command, cwd=cwd, env=env, stdout=output, stderr=subprocess.STDOUT)
    if result.returncode:
        print("\n".join(log.read_text().splitlines()[-80:]), flush=True)
        raise SystemExit(f"Command failed ({result.returncode}). See {log}")
    print(f"PASS: {log.name}", flush=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--simulator", required=True, help="Available iOS simulator UUID")
    parser.add_argument("--chainable-root", type=Path, help="Matching EGChainable checkout")
    parser.add_argument("--output", type=Path, help="New directory for logs, builds, and test results")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    chainable = (args.chainable_root or root.parent / "EGChainable").resolve()
    if not (chainable / "Package.swift").is_file():
        parser.error(f"No Package.swift in {chainable}")
    if args.output:
        work = args.output.resolve()
        work.mkdir(parents=True, exist_ok=False)
    else:
        work = Path(tempfile.mkdtemp(prefix="declarative-spm-"))
    print(f"Results: {work}", flush=True)
    consumer = work / "Consumer"
    sources = consumer / "Sources/Client"
    tests = consumer / "Tests/ConsumerTests"
    sources.mkdir(parents=True)
    tests.mkdir(parents=True)
    # Only the development fixture overrides the unpublished EGChainable package.
    consumer.joinpath("Package.swift").write_text('''// swift-tools-version: 5.9
import PackageDescription
let package = Package(
    name: "SPMConsumer",
    platforms: [.iOS("10.0")],
    products: [.library(name: "SPMConsumer", targets: ["Client"])],
    dependencies: [
        .package(path: %s),
        .package(path: %s)
    ],
    targets: [
        .target(name: "Client", dependencies: [
            .product(name: "EGDeclarativeUIKit", package: %s)
        ]),
        .testTarget(name: "ConsumerTests", dependencies: [
            "Client", .product(name: "EGDeclarativeUIKit", package: %s)
        ])
    ],
    swiftLanguageVersions: [.v5]
)
''' % (json.dumps(str(root), ensure_ascii=False), json.dumps(str(chainable), ensure_ascii=False),
       json.dumps(root.name), json.dumps(root.name)))
    sources.joinpath("Client.swift").write_text('''import UIKit
import EGDeclarativeUIKit
import EGChainable
import RxSwift
import Combine

func makeStaticView() -> UIView {
    VStack {
        UITextField().text("Email").keyboardType(.emailAddress)
        UIListView(with: .vertical) { UILabel("Row") }
        UIButton("Save").onTap {}
    }
}

@available(iOS 13.0, *)
func makeBoundView() -> UIView {
    VStack {
        UITextField().text(Observable.just("Email"))
        UILabel().text(Just("Title")).layout { $0.height.equalTo(44) }
    }
}
''')
    shutil.copyfile(root / "Example/Tests/Tests.swift", tests / "Tests.swift")
    tests.joinpath("ConsumerTests.swift").write_text('''import XCTest
@testable import Client

final class ConsumerTests: XCTestCase {
    func testSingleProductProvidesAllFeatures() {
        XCTAssertEqual(makeStaticView().subviews.count, 3)
        if #available(iOS 13.0, *) {
            XCTAssertEqual(makeBoundView().subviews.count, 2)
        }
    }
}
''')
    sdk = subprocess.check_output(["xcrun", "--sdk", "iphoneos", "--show-sdk-path"], text=True).strip()
    env = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(work / "modules"))
    triple = "arm64-apple-ios10.0"
    # SwiftPM raises old deployment targets. Check iOS 10 with explicit compiler targets.
    build = ["xcrun", "swift", "build", "--manifest-cache", "local", "--triple", triple,
             "--sdk", sdk, "-Xswiftc", "-target", "-Xswiftc", triple, "-Xcc", "-target", "-Xcc", triple]
    with (work / "deployment-targets.log").open("w") as deployment_log:
        for package, flags, objects in [
            (chainable, ["--scratch-path", str(work / "chainable-build")],
             ["EGChainable.build/UILabel+Chainable.swift.o"]),
            (consumer, [], ["EGDeclarativeUIKit.build/BodyBuilder.swift.o", "Client.build/Client.swift.o"])
        ]:
            command = build + ["--package-path", str(package)] + flags
            name = "chainable" if package == chainable else "consumer"
            run(command, work / f"{name}-build.log", cwd=work, env=env)
            binaries = Path(subprocess.check_output(command + ["--show-bin-path"], env=env, text=True).strip())
            for obj in objects:
                result = subprocess.check_output(["xcrun", "vtool", "-show-build", str(binaries / obj)], text=True)
                deployment_log.write(result)
                if not re.search(r"(?:version|minos)\s+10\.0\b", result):
                    raise SystemExit(f"Expected iOS 10 output: {binaries / obj}\n{result}")
    run(["xcodebuild", "build-for-testing", "-scheme", "SPMConsumer",
         "-destination", f"platform=iOS Simulator,id={args.simulator}",
         "-derivedDataPath", str(work / "DerivedData"),
         "CODE_SIGNING_ALLOWED=NO", "IPHONEOS_DEPLOYMENT_TARGET=13.0", "SWIFT_VERSION=5.0"],
        work / "build-tests.log", cwd=consumer, env=env)

    # UIKit target-action needs UIApplicationMain, which SPM's test runner does not call.
    host = work / "SPMTestHost.app"
    host.mkdir()
    host_source = work / "AppDelegate.swift"
    host_source.write_text("import UIKit\n@main final class AppDelegate: UIResponder, UIApplicationDelegate {}\n")
    host.joinpath("Info.plist").write_bytes(plistlib.dumps({
        "CFBundleIdentifier": "org.declarativeuikit.SPMTestHost",
        "CFBundleName": "SPMTestHost", "CFBundleExecutable": "SPMTestHost",
        "CFBundlePackageType": "APPL", "CFBundleVersion": "1", "CFBundleShortVersionString": "1.0",
        "MinimumOSVersion": "13.0", "LSRequiresIPhoneOS": True,
        "CFBundleSupportedPlatforms": ["iPhoneSimulator"]
    }))
    simulator_sdk = subprocess.check_output(
        ["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], text=True).strip()
    run(["xcrun", "--sdk", "iphonesimulator", "swiftc", "-swift-version", "5", "-parse-as-library",
         "-target", f"{platform.machine()}-apple-ios13.0-simulator", "-sdk", simulator_sdk,
         str(host_source), "-o", str(host / "SPMTestHost")], work / "host-build.log", cwd=work, env=env)

    products = work / "DerivedData/Build/Products"
    test_run = next(products.glob("*.xctestrun"))
    configuration = plistlib.loads(test_run.read_bytes())
    target = configuration["TestConfigurations"][0]["TestTargets"][0]
    shutil.copytree(products / "Debug-iphonesimulator/ConsumerTests.xctest", host / "PlugIns/ConsumerTests.xctest")
    target.update(IsAppHostedTestBundle=True, TestHostPath=str(host),
                  TestHostBundleIdentifier="org.declarativeuikit.SPMTestHost",
                  TestBundlePath="__TESTHOST__/PlugIns/ConsumerTests.xctest")
    target["DependentProductPaths"].append(str(host))
    target["TestingEnvironmentVariables"].update(
        DYLD_INSERT_LIBRARIES="__PLATFORMS__/iPhoneSimulator.platform/Developer/usr/lib/libXCTestBundleInject.dylib",
        XCInjectBundleInto="__TESTHOST__/SPMTestHost")
    test_run.write_bytes(plistlib.dumps(configuration))
    run(["xcodebuild", "test-without-building", "-xctestrun", str(test_run),
         "-destination", f"platform=iOS Simulator,id={args.simulator}",
         "-resultBundlePath", str(work / "Tests.xcresult")], work / "tests.log", cwd=consumer, env=env)
    print(f"SPM checks passed. Results: {work}", flush=True)


if __name__ == "__main__":
    main()
