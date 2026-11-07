# DeclarativeUIKit

[中文说明](README-zh.md)

Build UIKit view trees with Swift result builders. Keep native UIKit views, use normal UIKit APIs, and add bindings or layout helpers when needed.

The builder runs once when you call it. It does not rebuild the view tree when state changes. Bindings update individual properties. A second call to `body` adds more subviews.

## Requirements and installation

- Core and Ext: iOS 10 or later, with a Swift 5.4 or later compiler in Swift 5 language mode.
- Custom stack spacing: iOS 11 or later.
- Combine: iOS 13 or later.
- Optional dependencies can have their own minimum OS versions. The example lock file fixes the versions used for tests.

Use a local checkout to use the APIs in this revision. Adjust the path for your app:

```ruby
pod 'EGDeclarativeUIKit', :path => '../DeclarativeUIKit'
pod 'EGDeclarativeUIKit/Rx', :path => '../DeclarativeUIKit'       # optional
pod 'EGDeclarativeUIKit/Combine', :path => '../DeclarativeUIKit'  # optional
pod 'EGDeclarativeUIKit/SnapKit', :path => '../DeclarativeUIKit'  # optional
pod 'EGDeclarativeUIKit/Chainable', :path => '../DeclarativeUIKit' # optional
```

The default subspecs are Core and Ext. They do not require RxSwift, Combine, SnapKit, or EGChainable. `UIListView` is available only when SnapKit can be imported; it uses a scroll view and a stack, with no cell reuse.

## Build and configure views

```swift
import UIKit
import EGDeclarativeUIKit

let subtitle: UILabel? = UILabel("Choose an option")
let rows = ["Name", "Email"]

let content = VStack(spacing: 12, alignment: .fill) {
    UILabel("Account")
        .apply { $0.font = .preferredFont(forTextStyle: .title1) }
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

`UILabel("Title")` sets the text. `UIButton("Save")` creates a system button; pass `type: .custom` when needed. Use `apply` for other properties. Existing `assign(to:)` and `spacingAfterSelf` calls remain available.

With the Chainable subspec, `.C` is now provided by the library:

```swift
import EGChainable

let label = UILabel("Title").C.textColor(.black).asView()
```

## Bind values

The Rx and Combine subspecs each provide `bind(_:to:)` with a writable key path. Values can bind to matching optional properties, so a `String` source can set `UILabel.text` without a manual conversion.

```swift
// Combine; model.title is declared with @Published.
UILabel().bind(model.$title.map { $0.uppercased() }, to: \.text)
UIButton("Save").bind(model.$canSave, to: \.isEnabled)
UILabel().text(model.$title) // The short property methods also accept mapped publishers.

// RxSwift; model.title is declared with @RxUIPublished.
UILabel().bind(model.$title.map { $0.uppercased() }, to: \.text)
UILabel().R.text(model.$title) // Existing R methods use the same binding storage.
```

Binding rules:

- Create bindings on the main thread. Sources can send values from other threads; the binding delivers UI updates on the main thread.
- Combine accepts any `Publisher` with `Failure == Never`. It delivers values asynchronously on the main queue, including the initial value. Handle upstream errors before binding.
- Rx accepts `Observable`. A completed or failed stream leaves the last value in place. Handle errors upstream if the UI must show them. An emitted `nil` still clears an optional property.
- The view owns its subscriptions. The binding holds the view weakly and cancels subscriptions when the view is released. Removing a retained view from its parent does not cancel its bindings.
- A new binding to the same key path replaces the old binding within that reactive subspec. Rx and Combine have separate storage. Do not use both to drive one property.
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

These methods use target-action and support iOS 10. Each call adds a handler. The control keeps its handlers until it is released. Use weak captures for an owner that also retains the control.

## Apply layout

With the SnapKit subspec, `layout` returns the same view:

```swift
import SnapKit

view.body {
    UILabel("Title")
        .layout { $0.leading.trailing.equalToSuperview().inset(16) }
        .layout { $0.top.equalToSuperview().offset(24) }
}
```

Before a view has a parent, layout closures wait in registration order. `body` and the stack builders run them after adding the view, then release them. Pending work runs once; adding the view again does not repeat it. If the view already has a parent, layout runs immediately.

Native `addSubview` does not trigger pending work. For that path, add the view first, then call `layout`. The existing `applyAutoLayout` and `.S.makeConstraints` methods use the same execution rules. `layout` adds constraints; use SnapKit's own update or remake APIs when you need those operations.

## Migration notes

- A direct integer array in a builder now fails at compile time.
- Typed view arrays and `[BodyBuilderItemable]` work in builders. `addArranged(item:)` still accepts `[BodyBuilderItemable]` outside a builder.
- Arrays no longer conform to `BodyBuilderItemable` for every element type. Generic code that relied on that unrestricted conformance must use valid element types or an explicit builder item.
- `.asBuildItems` remains as a deprecated compatibility method. It checks elements at runtime and fails for invalid input. Prefer separate builder expressions or an explicitly typed `[BodyBuilderItemable]` for mixed views and chainable objects.
- Remove an app-local `.C` alias if it only repeats the library alias.

## Example and checks

See [the example controller](Example/DeclarativeUIKit/ViewController.swift) for a working Rx form with a switch, a save button, and text bindings.

```sh
pod install --project-directory=Example --deployment
bash scripts/check-core.sh
xcrun simctl list devices available
# Set SIMULATOR_ID to an available iPhone simulator UUID.
xcodebuild test \
  -workspace Example/DeclarativeUIKit.xcworkspace \
  -scheme DeclarativeUIKit-Example \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  CODE_SIGNING_ALLOWED=NO IPHONEOS_DEPLOYMENT_TARGET=13.0 SWIFT_VERSION=5.0
```

The test command overrides the deployment target for all build targets so current Xcode can build the old example and dependencies. It does not change the library's declared minimum version. The Core/Ext script separately compiles an iOS 10 target without optional dependencies and checks valid and invalid builder clients. Compilation does not prove behavior on an iOS 10 device. Swift 6 strict concurrency mode is not part of this revision's support claim.

GitHub Actions runs these checks on a current simulator. The tests cover builders, layout order, binding updates and release, replacement, thread delivery, button states, and control events.

## License

MIT. See [LICENSE](LICENSE).
