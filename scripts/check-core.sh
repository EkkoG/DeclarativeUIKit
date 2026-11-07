#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHECK_DIR="$(mktemp -d "${TMPDIR:-/tmp}/declarativeuikit-core.XXXXXX")"
trap 'rm -rf "$CHECK_DIR"' EXIT
SDK_PATH="$(xcrun --sdk iphonesimulator --show-sdk-path)"
SWIFT=(xcrun swiftc -swift-version 5 -sdk "$SDK_PATH"
    -target "$(uname -m)-apple-ios10.0-simulator" -module-cache-path "$CHECK_DIR/modules")

printf '#import <UIKit/UIKit.h>\n' > "$CHECK_DIR/UIKitImport.h"
"${SWIFT[@]}" -emit-module -parse-as-library -module-name EGDeclarativeUIKit \
    -emit-module-path "$CHECK_DIR/EGDeclarativeUIKit.swiftmodule" \
    -import-objc-header "$CHECK_DIR/UIKitImport.h" \
    "$REPO_ROOT"/DeclarativeUIKit/Classes/Core/*.swift \
    "$REPO_ROOT"/DeclarativeUIKit/Classes/Ext/*.swift

cat > "$CHECK_DIR/Valid.swift" <<'SWIFT'
import UIKit
import EGDeclarativeUIKit
func buildViews() {
    let items: [UIView] = [UILabel("Title"), UIView()]
    let stack = UIStackView.V { items }
    stack.addArranged(items)
    _ = UIView { [UILabel("One"), UILabel("Two")] }
    _ = HStack(spacing: 8) { UIButton("Save").onTap {} }
    _ = UISwitch().onValueChanged { control in _ = control.isOn }
    let _: UILabel = UILabel().set(\.layer.cornerRadius, to: 8).set(\.text, to: "Title")
}
SWIFT
"${SWIFT[@]}" -typecheck -I "$CHECK_DIR" "$CHECK_DIR/Valid.swift"

cat > "$CHECK_DIR/Invalid.swift" <<'SWIFT'
import UIKit
import EGDeclarativeUIKit
func invalid() { _ = UIView { [1, 2, 3] } }
SWIFT
if "${SWIFT[@]}" -typecheck -I "$CHECK_DIR" "$CHECK_DIR/Invalid.swift" > "$CHECK_DIR/invalid.log" 2>&1; then
    echo "ERROR: The builder accepted an integer array."
    exit 1
fi
if ! grep -Eq 'buildExpression|cannot convert.*Int.*UIView' "$CHECK_DIR/invalid.log"; then
    cat "$CHECK_DIR/invalid.log"
    exit 1
fi
for EXPRESSION in 'UIView().apply { _ in }' '[UIView()].asBuildItems' 'UIView().asView()'; do
    printf 'import UIKit\nimport EGDeclarativeUIKit\nfunc removed() { _ = %s }\n' "$EXPRESSION" > "$CHECK_DIR/Removed.swift"
    if "${SWIFT[@]}" -typecheck -I "$CHECK_DIR" "$CHECK_DIR/Removed.swift" > "$CHECK_DIR/removed.log" 2>&1; then
        echo "ERROR: A removed API still compiles: $EXPRESSION"
        exit 1
    fi
    if ! grep -q 'has no member' "$CHECK_DIR/removed.log"; then
        cat "$CHECK_DIR/removed.log"
        exit 1
    fi
done
echo "Core and Ext compile for iOS 10. The valid client passes; the invalid array is rejected."
