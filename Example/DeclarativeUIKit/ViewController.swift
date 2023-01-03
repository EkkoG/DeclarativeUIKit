//
//  ViewController.swift
//  DeclarativeUIKit
//
//  Created by 3138493 on 07/03/2022.
//  Copyright (c) 2022 3138493. All rights reserved.
//

import UIKit
import EGDeclarativeUIKit
import SnapKit
import RxSwift

import EGChainable

extension Chainable {
    public var C: ChainableObject<Self> {
        return chainable
    }
}

class ViewController: UIViewController {

    @RxUIPublished var text = "Hello"
    @RxUIPublished var text1 = "Hello"
    var stack: UIStackView?
    var ahh: [UIView]?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.text1 = "World"
        }
        view.body {
            [UIView().C.backgroundColor(.red), UILabel()].asBuildItems
            UIView().C.backgroundColor(.red)
            UIView().C.backgroundColor(.red).asView()
            UILabel().apply { label in
                label.R.text(Observable.combineLatest($text, $text1).flatMap { PublishSubject.just([$0, $1].joined(separator: " ")) })
                label.C.textColor(.black)
                        .text("Hello, World!")
                label.S.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().offset(70)
                }
            }
            UIView {

                UIView().alias("Round cornder backgound").body {
                    UIStackView.V {
                        UIListView(with: NSLayoutConstraint.Axis.horizontal) {
                            for i in 0..<50 {
                                UILabel().apply { label in
                                    label.C.text("\(i)").textAlignment(.center)
                                    label.C.backgroundColor(.random)
                                    label.S.makeConstraints { make in
                                        make.width.equalTo(30)
                                    }
                                }
                            }
                        }.apply { view in
                            view.S.makeConstraints { maker in
                                maker.height.equalTo(30)
                                maker.leading.trailing.equalToSuperview()
                            }
                        }
                        ["ahh", "ahhh"].map { s in
                            UILabel().apply { label in
                                label.C.text(s).textAlignment(.center)
                            }
                        }.assign(to: &ahh)
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
                                button.C.setTitle("ahhhhhhhhhhhhhhhh", for: .normal).setTitleColor(.white, for: .normal)
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

extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}
