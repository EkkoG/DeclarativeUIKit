# DeclarativeUIKit

[中文说明](README-zh.md)

Build UIKit view trees with Swift result builders. Keep native UIKit views, use normal UIKit APIs, and add bindings or layout helpers when needed.

The builder runs once when you call it. It does not rebuild the view tree when state changes. Bindings update individual properties. A second call to `body` adds more subviews.

## Requirements and installation

- iOS 15 or later, with Xcode 26.5 in Swift 5 language mode.
- New versions use Swift Package Manager only. CocoaPods support remains in older releases.

In Xcode, add `https://github.com/EkkoG/DeclarativeUIKit.git` and select the `EGDeclarativeUIKit` product. This single product includes Core, Ext, Rx, Combine, SnapKit, and all generated EGChainable types. There are no optional products or class selections.

Use `import EGDeclarativeUIKit` for builders, bindings, and layout, and `import EGChainable` for named static modifiers. Import `RxSwift`, `Combine`, or `SnapKit` where you use their types. You do not need to select another product for these features.

The package uses RxSwift/RxCocoa 6.x from 6.10.2 and SnapKit 6.x from 6.0.0. Their effective package manifests support the iOS 15 baseline. Combine and custom stack spacing are available throughout this baseline. `UIListView` uses a scroll view and a stack, with no cell reuse.

This support has not been published yet. Use a DeclarativeUIKit revision that contains this `Package.swift`; its EGChainable dependency also needs a published 0.3.x version with its package manifest. Older tags do not provide this setup. The example projects use relative local package paths for development only.

## Build and configure views

```swift
import UIKit
import EGDeclarativeUIKit
import EGChainable

let subtitle: UILabel? = UILabel("Choose an option")
let rows = ["Name", "Email"]

let content = VStack(spacing: 12, alignment: .fill) {
    UILabel("Account")
        .font(.preferredFont(forTextStyle: .title1))
    subtitle
    if !rows.isEmpty {
        UILabel("Details")
    }
    for title in rows {
        UILabel(title)
    }
    rows.map { UILabel($0) }
    UIButton("Save").onTap { print("Save") }
}
```

The builder accepts views, optional views, typed arrays, loops, and conditional branches. It preserves view order and identity. `HStack`, `VStack`, `UIStackView.H`, and `UIStackView.V` accept `spacing`, `alignment`, and `distribution`, with UIKit defaults.

`UILabel("Title")` sets the text. `UIButton("Save")` creates a system button; pass `type: .custom` when needed. Use the generated property methods for other UIKit properties. Existing `assign(to:)` and `spacingAfterSelf` calls remain available.

EGChainable adds methods that return the original object. Parent methods keep the concrete subclass type:

```swift
import EGChainable

let label = UILabel("Title").backgroundColor(.white).textColor(.black)
let email = UITextField().placeholder("Email").keyboardType(.emailAddress).accessibilityLabel("Email")
let controller = UIViewController().title("Profile").hidesBottomBarWhenPushed(true)
```

For a custom or nested property, Core provides a typed key-path setter: `label.set(\.layer.cornerRadius, to: 8)`. This returns the same object.

## Bind values

The Rx and Combine integrations each provide `bind(_:to:)` with a writable key path. Values can bind to matching optional properties, so a `String` source can set `UILabel.text` without a manual conversion.

```swift
// Combine; model.title is declared with @Published.
UILabel().bind(model.$title.map { $0.uppercased() }, to: \.text)
UIButton("Save").bind(model.$canSave, to: \.isEnabled)
UILabel().text(model.$title) // The short property methods also accept mapped publishers.

// RxSwift; model.title is declared with @RxUIPublished.
UILabel().bind(model.$title.map { $0.uppercased() }, to: \.text)
UILabel().text(model.$title) // Static values and reactive sources use the same method name.
```

Binding rules:

- Create bindings on the main thread. Sources can send values from other threads; the binding delivers UI updates on the main thread.
- Combine accepts any `Publisher` with `Failure == Never`. It delivers values asynchronously on the main queue, including the initial value. Handle upstream errors before binding.
- Rx accepts `Observable`. A completed or failed stream leaves the last value in place. Handle errors upstream if the UI must show them. An emitted `nil` still clears an optional property.
- The view owns its subscriptions. The binding holds the view weakly and cancels subscriptions when the view is released. Removing a retained view from its parent does not cancel its bindings.
- A new binding to the same key path replaces the old binding within that reactive integration. Rx and Combine have separate storage. Do not use both to drive one property.
- Static assignment, including `set`, does not cancel a binding. The next source value can replace it.
- Button methods such as `title(_:for:)` use both the field and control state as the replacement key. Normal and selected titles can stay bound at the same time.

Your own publisher operators and closures must also avoid strong reference cycles.

## Handle events

```swift
UIButton("Save").onTap { [weak self] in
    self?.save()
}

UISwitch().onValueChanged { control in
    print(control.isOn) // The parameter keeps its UISwitch type.
}
```

These methods use target-action. Each call adds a handler. The control keeps its handlers until it is released. Use weak captures for an owner that also retains the control.

## Apply layout

With the SnapKit integration, `layout` returns the same view:

```swift
import SnapKit

view.body {
    UILabel("Title")
        .layout { $0.leading.trailing.equalToSuperview().inset(16) }
        .layout { $0.top.equalToSuperview().offset(24) }
}
```

Before a view has a parent, layout closures wait in registration order. `body` and the stack builders run them after adding the view, then release them. Pending work runs once; adding the view again does not repeat it. If the view already has a parent, layout runs immediately.

Native `addSubview` does not trigger pending work. For that path, add the view first, then call `layout`. `layout` adds constraints; use SnapKit's own update or remake APIs when you need those operations.

## Migration from 0.1 to 0.2

This is a breaking change. No legacy wrappers or aliases remain.

| Previous call | New call |
|---|---|
| `.C.text("Title").asView()` | `.text("Title")` |
| `.R.text(source)` | `.text(source)` |
| `.S.makeConstraints { ... }` | `.layout { ... }` |
| `.apply { $0.font = font }` | `.font(font)` or `.set(\.font, to: font)` |
| `views.asBuildItems` | `views`, typed as `[UIView]` |
| `stack.addArranged(item: items)` | `stack.addArranged(views)` |

`BodyBuilderItemable` and the builder wrapper types are removed. Use `[UIView]` for mixed view arrays. Flatten nested arrays with `flatMap` before passing them to a builder. Invalid arrays such as `[Int]` fail at compile time. `applyAutoLayout` is no longer public; use `layout`. Remove app-local `.C` aliases.

EGChainable 0.3 removes `.chainable`, `.asBase()`, and all wrappers. It generates writable property methods and five UIButton state methods: `title`, `titleColor`, `image`, `backgroundImage`, and `attributedTitle`. Use native calls for commands such as `reloadData()` and `stopLoading()`; they do not return a chainable object.

## Maintain generated APIs

Keep the two repositories in sibling directories. EGChainable owns the generator and SDK selection. Generated files are committed; library users do not run the generator.

The generator discovers public UIKit subclasses of `UIView` and `UIViewController`, adds their required parents, and keeps the other explicit classes. The current SDK output has 166 classes and 1,283 static property methods. Each reactive module covers the same writable property set for 47 view classes: 657 property methods plus five UIButton state methods. Optional properties accept both optional and nonoptional sources. Inherited methods are counted once; input overloads are not extra properties.

This includes text fields, cells, page controls, pickers, and accessibility properties. UIKit's NSObject category properties are exposed through UIResponder for static calls and UIView for bindings. Controllers have static configuration only. Other frameworks keep their explicit selection, including WKWebView. Read-only, unavailable, and obsoleted properties are excluded. General operation methods keep their native calls.

```sh
python3 ../EGChainable/scripts/generate.py --declarative-root "$PWD"
python3 ../EGChainable/scripts/generate.py --declarative-root "$PWD" --check
```

The generator uses Xcode's `swift-symbolgraph-extract`, then compiles all static output before replacement. `manifest.json` in EGChainable records the toolchain, selection rules, static and reactive properties, and exclusions. Rx and Combine use this shared property model; they do not have separate property lists. Run this project's integration checks after changing reactive output.

## Example and checks

Keep the matching EGChainable checkout beside this repository. Open `Example/DeclarativeUIKit.xcodeproj` directly in Xcode. The project uses local Swift packages and does not need `pod install`. [The example controller](Example/DeclarativeUIKit/ViewController.swift) shows an Rx form with an email field, a switch, a save button, and text bindings.

```sh
xcrun simctl list devices available
# Set SIMULATOR_ID to an available iPhone simulator UUID.
bash scripts/check-core.sh
python3 scripts/check-spm.py --simulator "$SIMULATOR_ID"
xcodebuild test \
  -project Example/DeclarativeUIKit.xcodeproj \
  -scheme DeclarativeUIKit-Example \
  -derivedDataPath DerivedData \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.0
```

The SPM script builds EGChainable and an external consumer for iOS 15, reads the effective manifests of the resolved dependencies, and runs one consumer test. The consumer selects only EGDeclarativeUIKit and uses static methods, bindings, and layout. RxSwift and SnapKit resolve from their public URLs; the matching local EGChainable overrides its unpublished dependency. Logs and results remain in the printed temporary directory. Use `--output` to select a new directory.

The example App hosts the original 37 behavior tests, including UIKit control events that require `UIApplicationMain`. It uses SPM for all library dependencies. The Core/Ext script checks an iOS 15 target and valid and invalid builder clients. Tests run on the selected simulator; compilation does not prove execution on an iOS 15 device. Swift 6 strict concurrency mode is not part of this revision's support claim.

The Debug App keeps package symbols in its main executable so the test bundle can use its linked libraries. The test target imports the generated RxCocoaRuntime module map without linking a second copy of the packages.

GitHub Actions checks out both repositories and uses Xcode 26.5. Set `EGCHAINABLE_REF` or the manual workflow input to the matching EGChainable revision; that revision must be available on GitHub. CI also builds the EGChainable example and checks generated sources. Local changes do not run remote CI.

## License

MIT. See [LICENSE](LICENSE).
