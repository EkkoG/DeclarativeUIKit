# DeclarativeUIKit

用 Swift result builder 构建 UIKit 视图树，保留原生控件和命令式 UIKit 用法，按需接入状态绑定、SnapKit 和链式属性配置。

builder 在调用时执行一次。状态变化不会自动重建其中的条件分支或视图树；绑定只更新指定属性。再次调用 `body` 会继续添加子视图。

## 要求与安装

- iOS 15+，Xcode 26.5，使用 Swift 5 语言模式。
- 新版本仅支持 Swift Package Manager；需要 CocoaPods 的项目应继续使用旧版本。

在 Xcode 中添加 `https://github.com/EkkoG/DeclarativeUIKit.git`，选择 `EGDeclarativeUIKit` 产品。这个单一产品包含 Core、Ext、Rx、Combine、SnapKit 和 EGChainable 的全部生成类型，无需选择可选产品或按类安装。

builder、绑定和布局使用 `import EGDeclarativeUIKit`，具名静态配置使用 `import EGChainable`；使用 RxSwift、Combine 或 SnapKit 的类型时，正常导入对应模块，不需要额外选择产品。

依赖使用从 6.10.2 开始的 RxSwift/RxCocoa 6.x 和从 6.0.0 开始的 SnapKit 6.x，其有效包清单均兼容 iOS 15。Combine 和自定义 Stack 间距在整个支持范围内可用。`UIListView` 使用 ScrollView 加 Stack，不具备列表单元格复用。

当前支持尚未发布。需要使用包含这份 `Package.swift` 的 DeclarativeUIKit 版本，且 EGChainable 需要发布包含包清单的配套 0.3.x 版本；旧 tag 不包含这套配置。示例工程中的相对本地包路径仅用于开发联调。

## 创建与配置视图

```swift
import UIKit
import EGDeclarativeUIKit
import EGChainable

let subtitle: UILabel? = UILabel("请选择")
let rows = ["姓名", "邮箱"]

let content = VStack(spacing: 12, alignment: .fill) {
    UILabel("账户")
        .font(.preferredFont(forTextStyle: .title1))
    subtitle
    if !rows.isEmpty {
        UILabel("详细信息")
    }
    for title in rows {
        UILabel(title)
    }
    rows.map { UILabel($0) }
    UIButton("保存").onTap { print("Save") }
}
```

支持单个视图、可选视图、有明确元素类型的数组、循环和条件分支，保留对象身份与顺序。`HStack`、`VStack`、`UIStackView.H`、`UIStackView.V` 都可以设置 `spacing`、`alignment`、`distribution`，默认值沿用 UIKit。

`UILabel("标题")` 设置文字；`UIButton("保存")` 默认创建 system 按钮，可传入 `type: .custom`。其他 UIKit 属性使用生成的具名方法；原有 `assign(to:)`、`spacingAfterSelf` 仍可使用。

通过 EGChainable 直接调用属性方法。每个方法都返回原对象，父类方法也保留子类的具体类型：

```swift
import EGChainable

let label = UILabel("标题").backgroundColor(.white).textColor(.black)
let email = UITextField().placeholder("邮箱").keyboardType(.emailAddress).accessibilityLabel("邮箱")
let controller = UIViewController().title("账户").hidesBottomBarWhenPushed(true)
```

自定义或嵌套属性可使用 Core 的类型安全入口：`label.set(\.layer.cornerRadius, to: 8)`，同样返回原对象。

## 绑定状态

Rx 和 Combine 模块都提供接受可写 KeyPath 的 `bind(_:to:)`。支持非可选值绑定到对应的可选属性，例如 `String` 可以直接绑定到 `UILabel.text`。

```swift
// Combine：model.title 使用 @Published 声明。
UILabel().bind(model.$title.map { $0.uppercased() }, to: \.text)
UIButton("保存").bind(model.$canSave, to: \.isEnabled)
UILabel().text(model.$title)

// RxSwift：model.title 使用 @RxUIPublished 声明。
UILabel().bind(model.$title.map { $0.uppercased() }, to: \.text)
UILabel().text(model.$title)
```

绑定规则：

- 必须在主线程创建绑定。数据源可以从后台发值，UI 更新会交付到主线程。
- Combine 接受 `Failure == Never` 的任意 Publisher，支持 `map` 等操作符的结果。包括初始值在内，更新均异步交付到主队列。需要显示错误时，在上游处理错误。
- Rx 接受 Observable。完成或错误事件不会清空最后的值；需要显示错误时，在上游处理。源显式发送 `nil` 仍会清空可选属性。
- 视图持有订阅，绑定回调弱引用视图，视图释放时取消订阅。仅从父视图移除、但仍被其他对象持有的视图，不会自动取消订阅。
- 同一响应式模块内，对同一 KeyPath 再次绑定会替换旧订阅。Rx 与 Combine 的存储相互独立，避免让二者同时驱动一个属性。
- 静态赋值和 `set` 不会取消绑定；下一次数据源发值仍可覆盖该属性。
- 按钮 `title(_:for:)` 等方法按“字段＋控件状态”区分订阅，normal 与 selected 标题可以同时绑定。

上游操作符和用户闭包如果强引用视图，仍可能造成循环引用，需要由调用方处理。

## 处理事件

```swift
UIButton("保存").onTap { [weak self] in
    self?.save()
}

UISwitch().onValueChanged { control in
    print(control.isOn) // 保留 UISwitch 类型，无需转换。
}
```

底层使用 target-action。每次调用添加一个处理器，控件释放时一起释放。如果拥有者也持有控件，闭包应使用适当的弱引用。

## 配置布局

`layout` 使用已包含的 SnapKit，并返回原视图，可以继续链式调用：

```swift
import SnapKit

view.body {
    UILabel("标题")
        .layout { $0.leading.trailing.equalToSuperview().inset(16) }
        .layout { $0.top.equalToSuperview().offset(24) }
}
```

视图尚无父视图时，布局闭包按登记顺序等待。`body` 或 Stack builder 将视图加入父容器后执行它们，并释放闭包。待执行工作只执行一次，重新挂载不会重复执行；已有父视图时，新登记的布局立即执行。

原生 `addSubview` 不会触发待执行布局。在这种用法中，应先添加视图，再调用 `layout`。`layout` 添加约束；更新或重建约束请继续使用 SnapKit 的对应 API。

## 从 0.1 迁移到 0.2

这是不兼容旧 API 的更新，旧包装和别名已删除。

| 旧调用 | 新调用 |
|---|---|
| `.C.text("标题").asView()` | `.text("标题")` |
| `.R.text(source)` | `.text(source)` |
| `.S.makeConstraints { ... }` | `.layout { ... }` |
| `.apply { $0.font = font }` | `.font(font)` 或 `.set(\.font, to: font)` |
| `views.asBuildItems` | 直接传 `[UIView]` 数组 |
| `stack.addArranged(item: items)` | `stack.addArranged(views)` |

`BodyBuilderItemable` 和 builder 包装类型已删除。混合控件数组使用 `[UIView]`；嵌套数组先用 `flatMap` 展平。`[Int]` 等非法表达式在编译时拒绝。`applyAutoLayout` 不再是公共 API，使用 SnapKit 模块的 `layout`；应用中自建的 `.C` 别名也应删除。

EGChainable 0.3 同步删除 `.chainable`、`.asBase()` 及所有包装对象。它生成可写属性方法，以及 UIButton 的 `title`、`titleColor`、`image`、`backgroundImage`、`attributedTitle` 五个状态方法。`reloadData()`、`stopLoading()` 等操作继续原生调用，不提供链式返回适配。

## 维护生成代码

两个仓库应放在同级目录。生成器和 SDK 选择规则由 EGChainable 维护。生成文件随库提交，库的使用者无需运行生成器。

生成器自动发现 UIKit 中公开的 `UIView`、`UIViewController` 后代，补齐必要祖先，并保留其他显式选择的类。当前 SDK 产物包含 166 个类型、1,283 个静态属性方法；每个响应式模块覆盖 47 个视图类型的同一套可写属性，共 657 个属性方法，另有 5 个 UIButton 状态方法。可选属性同时接受可选和非可选数据源；继承方法只计一次，输入重载不重复计为属性。

覆盖包括输入框、Cell、分页、Picker 和 accessibility 属性。UIKit 为 NSObject 添加的 category 属性在静态配置中通过 UIResponder 提供，响应式通过 UIView 提供。控制器仅提供静态配置；其他框架仍按显式类型选择，包括 WKWebView。只读、不可用、已移除的属性不生成，普通操作方法继续原生调用。

```sh
python3 ../EGChainable/scripts/generate.py --declarative-root "$PWD"
python3 ../EGChainable/scripts/generate.py --declarative-root "$PWD" --check
```

生成器调用 Xcode 自带的 `swift-symbolgraph-extract`，所有静态产物编译通过后才替换旧文件。EGChainable 的 `manifest.json` 记录工具链、选择规则、静态与响应式属性和排除原因。Rx、Combine 共用该属性模型，不另设属性白名单。修改响应式产物后，还需运行本项目的集成检查。

## 示例与验证

将配套 EGChainable checkout 放在本仓库旁边，在 Xcode 中直接打开 `Example/DeclarativeUIKit.xcodeproj`。工程使用本地 Swift package，无需运行 `pod install`。[示例控制器](Example/DeclarativeUIKit/ViewController.swift) 展示带邮箱输入框、开关、保存按钮和文字绑定的 Rx 表单。

```sh
xcrun simctl list devices available
# 将 SIMULATOR_ID 设为可用的 iPhone 模拟器 UUID。
bash scripts/check-core.sh
python3 scripts/check-spm.py --simulator "$SIMULATOR_ID"
xcodebuild test \
  -project Example/DeclarativeUIKit.xcodeproj \
  -scheme DeclarativeUIKit-Example \
  -derivedDataPath DerivedData \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  CODE_SIGNING_ALLOWED=NO SWIFT_VERSION=5.0
```

SPM 脚本以正常 iOS 15 目标构建 EGChainable 和真实外部消费包，检查实际解析依赖的有效清单，并运行 1 项消费者测试。消费者只选择 EGDeclarativeUIKit 产品，使用静态方法、绑定和布局。RxSwift、SnapKit 从公开 URL 解析，尚未发布的 EGChainable 使用配套本地源码覆盖。日志和结果保留在输出的临时目录，也可用 `--output` 指定新目录。

正式示例 App 承载原有 37 项行为测试，包括需要 `UIApplicationMain` 的 UIKit 控件事件；所有库依赖均通过 SPM 提供。Core/Ext 脚本检查 iOS 15 目标下的合法与非法 builder 客户端。测试运行在选定模拟器上，编译通过不等于 iOS 15 设备运行验证；本次不承诺 Swift 6 严格并发模式。

Debug App 将包符号保留在主可执行文件中，测试 bundle 通过宿主复用已链接的库。测试目标只导入生成的 RxCocoaRuntime module map，不再链接第二份包，避免重复加载类。

GitHub Actions 同时检出两个仓库并使用 Xcode 26.5。通过 `EGCHAINABLE_REF` 或手动工作流参数指定配套 EGChainable 版本，该版本必须已在 GitHub 上可用。CI 还会构建 EGChainable 示例并检查生成一致性；本地改动不会自动运行远端 CI。

## 开源协议

MIT，详见 [LICENSE](LICENSE)。
