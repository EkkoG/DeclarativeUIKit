//
//  ViewController.swift
//  DeclarativeUIKit
//
//  Created by 3138493 on 07/03/2022.
//  Copyright (c) 2022 3138493. All rights reserved.
//

import UIKit
import DeclarativeUIKit
import ApplyStyleKit
import SnapKit
import RxSwift

class ViewController: UIViewController {

    @RxUIPublished var text = "Hello"
    @RxUIPublished var text1 = "Hello"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var stack: UIStackView?
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
                UIView().alias("圆角背景").body {
                    UIStackView.V {
                        UISpace().apply { space in
                            space.S.height(32)
                        }
                        UILabel().alias("标题").apply { label in
                            label.text = "Delete your account?"
                        }.spacingAfterSelf(8)
                        UIStackView.H {
                            UILabel().apply { label in
                                label.text = "ahh"
                            }
                            UILabel().alias("红色警告").apply { label in
                                label.text = "Deleting account is permanent"
                                label.textColor = .red.withAlphaComponent(0.4)
                            }
                        }
                        UILabel().alias("长文本，解释").apply { label in
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
                        make.width.height.equalTo(300)
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

