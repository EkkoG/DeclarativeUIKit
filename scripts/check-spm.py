#!/usr/bin/env python3
"""Build the Swift packages and test an external single-product consumer."""

import argparse
import json
import os
from pathlib import Path
import platform
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
    consumer.joinpath("Package.swift").write_text('''// swift-tools-version: 6.0
import PackageDescription
let package = Package(
    name: "SPMConsumer",
    platforms: [.iOS(.v15)],
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
    swiftLanguageModes: [.v5]
)
''' % (json.dumps(str(root), ensure_ascii=False), json.dumps(str(chainable), ensure_ascii=False),
       json.dumps(root.name), json.dumps(root.name)))
    shutil.copyfile(root / "Example/DeclarativeUIKit/ViewController.swift", sources / "ViewController.swift")
    tests.joinpath("ConsumerTests.swift").write_text('''import XCTest
import UIKit
import EGDeclarativeUIKit
import EGChainable
import RxSwift
import Combine
@testable import Client

final class ConsumerTests: XCTestCase {
    func testLegacyWrappersAndBuilder() {
        let label = UILabel()
        let wrapped = label.C.text("Legacy").textColor(.red)
        XCTAssertTrue(wrapped.asView() === label)
        XCTAssertTrue(wrapped.asBase() === label)
        let parent = UIView {
            wrapped
            [UIButton(), UIView()].asBuildItems
        }
        XCTAssertEqual(parent.subviews.count, 3)
        XCTAssertTrue(parent.subviews.first === label)
        XCTAssertEqual(label.text, "Legacy")
    }

    func testLegacyApplyAndSnapKitLayout() {
        let child = UIView().apply { view in
            view.S.makeConstraints { make in
                make.width.equalTo(44)
                make.height.equalTo(22)
            }
        }
        let parent = UIView { child }
        XCTAssertTrue(child.superview === parent)
        XCTAssertEqual(child.constraints.count, 2)
    }

    func testLegacyReactiveImports() {
        let source = BehaviorSubject(value: "Rx")
        let label = UILabel()
        label.R.text(source)
        XCTAssertEqual(label.text, "Rx")
        source.onNext("Updated")
        XCTAssertEqual(label.text, "Updated")

        final class Model {
            @Published var title = "Combine"
        }
        let model = Model()
        let combined = UILabel().text(model.$title)
        XCTAssertEqual(combined.text, "Combine")
    }

    func testOriginalExampleLoads() {
        let controller = ViewController()
        controller.loadViewIfNeeded()
        XCTAssertFalse(controller.view.subviews.isEmpty)
    }
}
''')
    sdk = subprocess.check_output(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], text=True).strip()
    env = dict(os.environ, CLANG_MODULE_CACHE_PATH=str(work / "modules"))
    triple = f"{platform.machine()}-apple-ios15.0-simulator"
    build = ["xcrun", "swift", "build", "--manifest-cache", "local", "--triple", triple,
             "--sdk", sdk]
    run(build + ["--package-path", str(chainable), "--scratch-path", str(work / "chainable-build")],
        work / "chainable-build.log", cwd=work, env=env)
    run(build + ["--package-path", str(consumer)], work / "consumer-build.log", cwd=work, env=env)

    # Let SwiftPM select versioned manifests, such as Package@swift-5.9.swift.
    for package in [root, chainable, consumer / ".build/checkouts/RxSwift", consumer / ".build/checkouts/SnapKit"]:
        manifest = subprocess.check_output(
            ["xcrun", "swift", "package", "--package-path", str(package), "dump-package"], env=env, text=True)
        (work / f"{package.name}-manifest.json").write_text(manifest)
        description = json.loads(manifest)
        minimum = next(p["version"] for p in description["platforms"] if p["platformName"] == "ios")
        if tuple(map(int, minimum.split("."))) > (15, 0):
            raise SystemExit(f"{package.name} requires iOS {minimum}; the library supports iOS 15")
        print(f"PASS: {package.name} declares iOS {minimum}", flush=True)

    run(["xcodebuild", "test", "-scheme", "SPMConsumer",
         "-destination", f"platform=iOS Simulator,id={args.simulator}",
         "-derivedDataPath", str(work / "DerivedData"),
         "-resultBundlePath", str(work / "Tests.xcresult"),
         "CODE_SIGNING_ALLOWED=NO", "SWIFT_VERSION=5.0"], work / "tests.log", cwd=consumer, env=env)
    print(f"SPM checks passed. Results: {work}", flush=True)


if __name__ == "__main__":
    main()
