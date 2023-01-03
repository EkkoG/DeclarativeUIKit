# DeclarativeUIKit

[中文介绍](README-zh.md)

A simple library(only 200 lines of code of [Core](https://github.com/EkkoG/DeclarativeUIKit/tree/master/DeclarativeUIKit/Classes/Core)) make UIKit declaretive like SwiftUI, no custom component, all UIKit original component.

Use [EGChainable](https://github.com/EkkoG/EGChainable) to call API chainable.

Use [RxSwift](https://github.com/ReactiveX/RxSwift) to make UI component update automatic when data update.

Also work perfectly with Autolayout or it's API wrapper like SnapKit, no limit when apply layout constraint in resulutBuilder.

When something DeclarativeUIKit can't do, you can do it imperative way, like normal UIKit usage, it's ok.

## Usage

https://github.com/EkkoG/DeclarativeUIKit/blob/5a4a20ad1a9abc67d9897915250f4ea7e84797ad/Example/DeclarativeUIKit/ViewController.swift#L22-L144

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 10+

## Installation

DeclarativeUIKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EGDeclarativeUIKit'
```

## Author

EkkoG, beijiu572@gmail.com

## License

DeclarativeUIKit is available under the MIT license. See the LICENSE file for more info.
