//
// Created by Kevin Guo on 2022/7/4.
//

import Foundation

public class CircleView: UIView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}