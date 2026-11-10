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

- CocoaPods: iOS 10+ (Combine requires iOS 13+).
- Swift Package Manager: iOS 15+, Xcode 26.5, Swift 5 language mode.

## Installation

### Swift Package Manager

Add `https://github.com/EkkoG/DeclarativeUIKit.git` in Xcode, select the `codex/spm-backport` branch, and add the `EGDeclarativeUIKit` product. It includes Core, Ext, Chainable, Rx, Combine, and SnapKit. Import `EGDeclarativeUIKit`, and import `EGChainable`, `RxSwift`, or `SnapKit` when you use their APIs.

This branch adds SPM to the original API. It retains `apply`, `asBuildItems`, `asView`, `.R`, `.S`, and `.chainable`. The example's `.C` alias remains defined in the example. SPM uses the matching `codex/spm-backport` branch of EGChainable, RxSwift/RxCocoa 6.10.2 or later in 6.x, and SnapKit 6.0.0 or later in 6.x. Both branches must be pushed before remote installation can work.

For local checks, keep the matching EGChainable checkout beside this repository and run:

```sh
xcrun simctl list devices available
# Set SIMULATOR_ID to an available iPhone simulator UUID.
python3 scripts/check-spm.py --simulator "$SIMULATOR_ID"
```

The check builds both packages, compiles the original example in a consumer that selects only the `EGDeclarativeUIKit` product, and runs four smoke tests. The local EGChainable override is for this check only. The existing example project still uses CocoaPods.

### CocoaPods

DeclarativeUIKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EGDeclarativeUIKit'
```

## Author

EkkoG, beijiu572@gmail.com

## License

DeclarativeUIKit is available under the MIT license. See the LICENSE file for more info.
