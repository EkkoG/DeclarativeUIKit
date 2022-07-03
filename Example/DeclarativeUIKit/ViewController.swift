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
        var label: UILabel?
        var label2: UILabel?
        var stack: VStack?
        view.body {
            VStack {
                UILabel(frame: .zero).assign(to: &label).apply { label in
                    label.backgroundColor = .red
                }
                if Int.random(in: 0..<2) > 0 {

                    UILabel(frame: .zero).assign(to: &label2).apply { label in
                        label.backgroundColor = .yellow
                    }
                } else {
                    UILabel(frame: .zero).assign(to: &label2).apply { label in
                        label.backgroundColor = .green
                    }
                }
            }
                    .apply { stacksss in
                        (stacksss as! UIStackView).distribution = .fillEqually
                    }
                    .assign(to: &stack).applyAutoLayout { stack in
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

