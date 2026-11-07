# DeclarativeUIKit

用 Swift result builder 构建 UIKit 视图树，保留原生控件和命令式 UIKit 用法，按需接入状态绑定、SnapKit 和链式属性配置。

builder 在调用时执行一次。状态变化不会自动重建其中的条件分支或视图树；绑定只更新指定属性。再次调用 `body` 会继续添加子视图。

## 要求与安装

- Core、Ext：iOS 10+，Xcode 26.5，使用 Swift 5 语言模式。
- 自定义 Stack 间距：iOS 11+。
- Combine：iOS 13+。
- 可选依赖有各自的系统要求；示例的锁文件固定了本项目验证使用的依赖版本。

使用当前源码版本时，指向本地 checkout；根据应用目录调整路径：

```ruby
pod 'EGDeclarativeUIKit', :path => '../DeclarativeUIKit'
pod 'EGDeclarativeUIKit/Rx', :path => '../DeclarativeUIKit'       # 按需
pod 'EGDeclarativeUIKit/Combine', :path => '../DeclarativeUIKit'  # 按需
pod 'EGDeclarativeUIKit/SnapKit', :path => '../DeclarativeUIKit'  # 按需
pod 'EGDeclarativeUIKit/Chainable', :path => '../DeclarativeUIKit' # 按需
pod 'EGChainable', :path => '../EGChainable' # 本地 Chainable 新版所需
```

默认安装 Core 和 Ext，不强制引入 RxSwift、Combine、SnapKit 或 EGChainable。`UIListView` 仅在可导入 SnapKit 时可用；其实现是 ScrollView 加 Stack，不具备列表单元格复用。

## 创建与配置视图

```swift
import UIKit
import EGDeclarativeUIKit
import EGChainable // 具名静态配置需要安装 Chainable 模块。

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

安装 Chainable 模块后，直接调用属性方法。每个方法都返回原对象，父类方法也保留子类的具体类型：

```swift
import EGChainable

let label = UILabel("标题").backgroundColor(.white).textColor(.black)
let email = UITextField().placeholder("邮箱").keyboardType(.emailAddress).accessibilityLabel("邮箱")
let controller = UIViewController().title("账户").hidesBottomBarWhenPushed(true)
```

自定义或嵌套属性可使用 Core 的类型安全入口：`label.set(\.layer.cornerRadius, to: 8)`，同样返回原对象。未安装 Chainable 时，可以使用 `set` 或原生 UIKit 赋值。

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

底层使用 target-action，支持 iOS 10。每次调用添加一个处理器，控件释放时一起释放。如果拥有者也持有控件，闭包应使用适当的弱引用。

## 配置布局

安装 SnapKit 模块后，`layout` 返回原视图，可以继续链式调用：

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

[示例控制器](Example/DeclarativeUIKit/ViewController.swift) 展示了带邮箱输入框、开关、保存按钮和文字绑定的 Rx 表单。

```sh
pod install --project-directory=Example --deployment
bash scripts/check-core.sh
xcrun simctl list devices available
# 将 SIMULATOR_ID 设为可用 iPhone 模拟器的 UUID。
xcodebuild test \
  -workspace Example/DeclarativeUIKit.xcworkspace \
  -scheme DeclarativeUIKit-Example \
  -derivedDataPath DerivedData \
  -destination "platform=iOS Simulator,id=$SIMULATOR_ID" \
  CODE_SIGNING_ALLOWED=NO IPHONEOS_DEPLOYMENT_TARGET=13.0 SWIFT_VERSION=5.0
python3 scripts/check-modules.py DerivedData/Build/Products/Debug-iphonesimulator
```

测试命令会对所有构建目标覆盖部署版本，使当前 Xcode 能构建较早的示例和依赖，不改变库声明的最低系统版本。Core/Ext 脚本另行验证不引入可选依赖的 iOS 10 目标编译，以及合法客户端通过、非法 builder 数组被拒绝。编译检查不等于 iOS 10 设备运行验证；本次也不承诺 Swift 6 严格并发模式。

GitHub Actions 同时检出两个仓库并使用 Xcode 26.5。通过仓库变量 `EGCHAINABLE_REF` 或手动工作流参数指定配套 EGChainable 版本；该版本必须已在 GitHub 上可用，CI 才能使用。本地改动不会自动运行远端 CI。测试覆盖构建、布局顺序、绑定持续更新与释放、重绑、线程交付、按钮状态和控件事件。

## 开源协议

MIT，详见 [LICENSE](LICENSE)。
