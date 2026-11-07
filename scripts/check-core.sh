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
    let items: [BodyBuilderItemable] = [UILabel("Title"), UIView()]
    let stack = UIStackView.V { items }
    stack.addArranged(item: items)
    _ = UIView { [UILabel("One"), UILabel("Two")] }
    _ = HStack(spacing: 8) { UIButton("Save").onTap {} }
    _ = UISwitch().onValueChanged { control in _ = control.isOn }
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
if ! grep -q 'BodyBuilderItemable' "$CHECK_DIR/invalid.log"; then
    cat "$CHECK_DIR/invalid.log"
    exit 1
fi
echo "Core and Ext compile for iOS 10. The valid client passes; the invalid array is rejected."
