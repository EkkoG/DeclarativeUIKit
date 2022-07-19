# DeclarativeUIKit

[中文介绍](README-zh.md)

A simple library(only 200+ line of code of Core) make UIKit declaretive like SwiftUI, no custom component, all UIKit original component.

Use [ApplyStyleKit](https://github.com/shindyu/ApplyStyleKit) to call API chainable.

Use [RxSwift](https://github.com/ReactiveX/RxSwift) to make UI component update automatic when data update.

Also work perfectly with Autolayout or it's API wrapper like SnapKit, no limit when apply layout constraint in resulutBuilder.

When something DeclarativeUIKit can't do, you can do it imperative way, like normal UIKit usage, it's ok.

## Usage

```swift
class ViewController: UIViewController {

    @RxUIPublished var text = "Hello"
    @RxUIPublished var text1 = "Hello"
    var stack: UIStackView?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.text1 = "World"
        }
        view.body {
            UILabel().apply { label in
                label.R.text(Observable.combineLatest($text, $text1).flatMap { PublishSubject.just([$0, $1].joined(separator: " ")) })
                label.A.textColor(.black)
                        .text("Hello, World!")
                label.S.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().offset(70)
                }
            }
            UIView {

                UIView().alias("Round cornder backgound").body {
                    UIStackView.V {
                        UIStackView.H {
                            for i in 0..<5 {
                                UILabel().apply { label in
                                    label.A.text("\(i)").textAlignment(.center)
                                }
                            }
                        }.apply { view in
                            view.distribution = .fillEqually
                            view.S.makeConstraints { maker in
                                maker.height.equalTo(30)
                                maker.leading.trailing.equalToSuperview()
                            }
                        }
                        ["ahh", "ahhh"].map { s in
                            UILabel().apply { label in
                                label.A.text(s).textAlignment(.center)
                            }
                        }
                        UILabel().alias("Title").apply { label in
                            label.text = "Delete your account?"
                        }.spacingAfterSelf(8)
                        UIStackView.H {
                            UILabel().apply { label in
                                label.text = "ahh"
                            }
                            UILabel().alias("Red Alert").apply { label in
                                label.text = "Deleting account is permanent"
                                label.textColor = .red.withAlphaComponent(0.4)
                            }
                        }
                        UILabel().alias("Long text, desc of alert.").apply { label in
                            label.text = "Your Favourite Meditation and Music、your progress of mediation journey will be permanently deleted."
                            label.numberOfLines = 0
                            label.textAlignment = .center
                            label.S.makeConstraints { make in
                                make.leading.equalToSuperview().offset(16)
                                make.trailing.equalToSuperview().offset(-16)
                            }
                        }.spacingAfterSelf(20)

                        CircleView {
                            UIButton().apply { button in
                                button.setTitle("Continue Deleting Account", for: .normal)
                                button.setTitleColor(.white, for: .normal)
                                button.S.makeConstraints { make in
                                    make.edges.equalToSuperview()
                                    make.width.equalTo(250)
                                    make.height.equalTo(40)
                                }
                            }
                        }.apply { view in
                            view.backgroundColor = .red.withAlphaComponent(0.6)
                        }.spacingAfterSelf(10)
                        CircleView {
                            UIButton().apply { button in
                                button.setTitle("Cancel", for: .normal)
                                button.setTitleColor(.white, for: .normal)
                                button.S.makeConstraints { make in
                                    make.edges.equalToSuperview()
                                    make.width.equalTo(250)
                                    make.height.equalTo(40)
                                }
                            }
                        }.apply { view in
                            view.backgroundColor = .gray.withAlphaComponent(0.6)
                        }
                        UISpace()
                    }.apply { stack in
                        stack.alignment = .center
                        stack.S.makeConstraints { make in
                            make.edges.equalToSuperview()
                        }
                    }.assign(to: &stack)
                }.apply { view in
                    view.backgroundColor = .white
                    view.layer.cornerRadius = 8
                    view.clipsToBounds = true
                    view.S.makeConstraints { make in
                        make.width.equalTo(300)
                        make.height.equalTo(400)
                        make.center.equalToSuperview()
                    }
                }
            }.apply { view in
                view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
                view.S.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

```
## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

iOS 10+

## Installation

DeclarativeUIKit is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'EGDeclarativeUIKit', :git => 'https://github.com/EkkoG/DeclarativeUIKit.git'
```

## Author

EkkoG, beijiu572@gmail.com

## License

DeclarativeUIKit is available under the MIT license. See the LICENSE file for more info.
