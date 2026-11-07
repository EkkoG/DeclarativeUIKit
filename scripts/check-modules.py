#!/usr/bin/env python3
"""Compile independent module clients with the example's built dependencies."""

import argparse
from pathlib import Path
import platform
import subprocess
import tempfile


def run(command):
    subprocess.run(command, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("products", type=Path, help="DerivedData/Build/Products/Debug-iphonesimulator")
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[1]
    source = root / "DeclarativeUIKit/Classes"
    sdk = subprocess.check_output(["xcrun", "--sdk", "iphonesimulator", "--show-sdk-path"], text=True).strip()
    with tempfile.TemporaryDirectory(prefix="declarative-modules-") as temporary:
        work = Path(temporary)
        header = work / "UIKitImport.h"
        header.write_text("#import <UIKit/UIKit.h>\n")
        compiler = ["xcrun", "swiftc", "-swift-version", "5", "-sdk", sdk,
                    "-target", f"{platform.machine()}-apple-ios13.0-simulator",
                    "-module-cache-path", str(work / "modules")]
        static = work / "EGChainable.swiftmodule"
        generated = root.parent / "EGChainable/EGChainable/Classes/Generated"
        run(compiler + ["-emit-module", "-parse-as-library", "-module-name", "EGChainable",
                        "-emit-module-path", str(static)] + [str(p) for p in sorted(generated.glob("*.swift"))])
        cases = {
            "chainable": ([], [], '''
                let _: UITextField = UITextField().text("Email").keyboardType(.emailAddress).accessibilityLabel(nil)
                let _: UIViewController = UIViewController().title("Profile")
                let _: UITableViewCell = UITableViewCell().selectionStyle(.none)
            '''),
            "rx": (["Rx"], ["RxSwift", "RxCocoa", "RxRelay"], '''
                let _: UITextField = UITextField().text(Observable.just("Rx")).keyboardType(.just(.emailAddress))
                    .accessibilityLabel(Observable<String?>.just(nil))
                let _: UIPageControl = UIPageControl().numberOfPages(.just(3))
                let _: WKWebView = WKWebView().customUserAgent(Observable.just("Example"))
                if #available(iOS 17.4, *) { _ = UIStandardTextCursorView().isBlinking(.just(true)) }
            '''),
            "combine": (["Combine"], [], '''
                let _: UITextField = UITextField().text(Just<String?>(nil)).keyboardType(Just(UIKeyboardType.emailAddress))
                    .accessibilityLabel(Just("Email"))
                let _: UIPageControl = UIPageControl().numberOfPages(Just(3))
                let _: WKWebView = WKWebView().customUserAgent(Just("Example"))
                if #available(iOS 17.4, *) { _ = UIStandardTextCursorView().isBlinking(Just(true)) }
            '''),
            "snapkit": (["SnapKit"], ["SnapKit"], 'let _ = UIView { UILabel("Title").layout { $0.height.equalTo(44) } }'),
            "ext-with-external-snapkit": ([], ["SnapKit"], 'let _ = UIListView(with: .vertical) { UILabel("Title") }'),
            "all": (["Rx", "Combine", "SnapKit"], ["RxSwift", "RxCocoa", "RxRelay", "SnapKit"],
                    '''
                        let _: UITextField = UITextField().text("Static").text(Observable.just("Rx"))
                            .text(Just<String?>(nil)).accessibilityLabel("Email").keyboardType(.emailAddress)
                        if #available(iOS 18.0, *) {
                            let value: @MainActor @Sendable () -> UIAccessibility.ExpandedStatus = { .expanded }
                            let _ = UIView().accessibilityExpandedStatusBlock(Observable.just(value))
                                .accessibilityExpandedStatusBlock(Just(Optional(value)))
                        }
                    '''),
        }
        for name, (folders, frameworks, expression) in cases.items():
            directory = work / name
            directory.mkdir()
            flags = sum((["-F", str(args.products / framework)] for framework in frameworks), [])
            files = sorted(p for folder in ["Core", "Ext"] + folders for p in (source / folder).rglob("*.swift"))
            run(compiler + flags + ["-emit-module", "-parse-as-library", "-module-name", "EGDeclarativeUIKit",
                                    "-import-objc-header", str(header), "-emit-module-path",
                                    str(directory / "EGDeclarativeUIKit.swiftmodule")] + [str(p) for p in files])
            imports = ["UIKit", "WebKit", "EGDeclarativeUIKit"]
            if name in ("chainable", "all"):
                imports.append("EGChainable")
            imports += ["Combine"] if "Combine" in folders else []
            imports += frameworks
            client = directory / "Client.swift"
            prefix = "\n".join("import " + module for module in imports)
            client.write_text(prefix + "\nfunc checkClient() { " + expression + " }\n")
            run(compiler + flags + ["-typecheck", "-I", str(directory), "-I", str(work), str(client)])
            if name == "all":
                for old in ("UIView().R", "UIView().C", "UIView().S", "UILabel().chainable", "UILabel().asBase()",
                            "UIView().safeAreaLayoutGuide(UILayoutGuide())",
                            "UIViewController().bind(Just<String?>(nil), to: \\.title)",
                            "NSObject().bind(Just<String?>(nil), to: \\.accessibilityLabel)"):
                    client.write_text(prefix + "\nfunc removed() { _ = " + old + " }\n")
                    failed = subprocess.run(compiler + flags + ["-typecheck", "-I", str(directory), "-I", str(work), str(client)],
                                            capture_output=True, text=True)
                    if failed.returncode == 0 or not any(message in failed.stderr for message in ("has no member", "cannot call value")):
                        raise RuntimeError(f"Unexpected result for {old}:\n{failed.stderr}")
            print(f"PASS: {name}", flush=True)


if __name__ == "__main__":
    main()
