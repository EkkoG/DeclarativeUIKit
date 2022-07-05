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
        var stack: VStack?
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.text1 = "World"
        }
        view.body {
            UILabel().text(Observable.combineLatest($text, $text1).flatMap { PublishSubject.just([$0, $1].joined(separator: " ")) }).apply { label in
                label.text = "Hello, World!"
            }.A.textColor(.black).asView.applyAutoLayout { view in
                view.snp.makeConstraints { make in
                    make.centerX.equalToSuperview()
                    make.top.equalToSuperview().offset(70)
                }
            }
            UIView {
                UIView().alias("圆角背景").body {
                    VStack {
                        UISpace().applyAutoLayout { view in
                            view.snp.makeConstraints { make in
                                make.height.equalTo(32)
                            }
                        }
                        UILabel().alias("标题").apply { label in
                            label.text = "Delete your account?"
                        }.customSpacing(8)
                        HStack {
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
                        }.applyAutoLayout { view in
                            view.snp.makeConstraints { make in
                                make.leading.equalToSuperview().offset(16)
                                make.trailing.equalToSuperview().offset(-16)
                            }
                        }.customSpacing(20)

                        CircleView {
                            UIButton().apply { button in
                                button.setTitle("Continue Deleting Account", for: .normal)
                                button.setTitleColor(.white, for: .normal)
                            }.applyAutoLayout { view in
                                view.snp.makeConstraints { make in
                                    make.edges.equalToSuperview()
                                    make.width.equalTo(250)
                                    make.height.equalTo(40)
                                }
                            }
                        }.apply { view in
                            view.backgroundColor = .red.withAlphaComponent(0.6)
                        }.customSpacing(10)
                        CircleView {
                            UIButton().apply { button in
                                button.setTitle("Cancel", for: .normal)
                                button.setTitleColor(.white, for: .normal)
                            }.applyAutoLayout { view in
                                view.snp.makeConstraints { make in
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
                    }.assign(to: &stack).applyAutoLayout { stack in
                        stack.snp.makeConstraints { make in
                            make.edges.equalToSuperview()
                        }
                    }
                }.apply { view in
                    view.backgroundColor = .white
                    view.layer.cornerRadius = 8
                    view.clipsToBounds = true
                }.applyAutoLayout { view in
                    view.snp.makeConstraints { make in
                        make.width.height.equalTo(300)
                        make.center.equalToSuperview()
                    }
                }
            }.applyAutoLayout { view in
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }.apply { view in
                view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

