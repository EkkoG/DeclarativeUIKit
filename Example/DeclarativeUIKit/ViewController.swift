//
//  ViewController.swift
//  DeclarativeUIKit
//
//  Created by 3138493 on 07/03/2022.
//  Copyright (c) 2022 3138493. All rights reserved.
//

import UIKit
import DeclarativeUIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        var stack: VStack?
        view.body {
            UILabel().apply { label in
                label.text = "Hello, World!"
            }.applyAutoLayout { view in
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
                        }
                        UISpace().applyAutoLayout { view in
                            view.snp.makeConstraints { make in
                                make.height.equalTo(8)
                            }
                        }
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
                        }
                        UISpace().applyAutoLayout { view in
                            view.snp.makeConstraints { make in
                                make.height.equalTo(40)
                            }
                        }

                        UIButton().apply { button in
                            button.setTitle("Continue Deleting Account", for: .normal)
                            button.setTitleColor(.black, for: .normal)
                        }
                        UIButton().apply { button in
                            button.setTitle("Cancel", for: .normal)
                            button.setTitleColor(.black, for: .normal)
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

