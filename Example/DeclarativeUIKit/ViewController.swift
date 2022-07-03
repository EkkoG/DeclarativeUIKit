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
            VStack {
                UILabel().apply { label in
                    label.backgroundColor = .red
                    label.text = "ahh"
                }
                if Int.random(in: 0..<2) > 0 {

                    UILabel().apply { label in
                        label.backgroundColor = .yellow
                    }
                } else {
                    UILabel().apply { label in
                        label.backgroundColor = .green
                    }
                }

                UIButton().apply { button in
                    button.setTitle("ahh", for: .normal)
                    button.setTitleColor(.black, for: .normal)
                }
            }.apply { stack in
                        stack.distribution = .fillEqually
                    }.assign(to: &stack).applyAutoLayout { stack in
                        stack.snp.makeConstraints { make in
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

