//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

open class HStack: UIStackView {
    public convenience init(@BodyBuilder arrangedSubviewsBuilder: () -> BodyBuilderItemable) {
        self.init(_arrangedSubviewsBuilder: arrangedSubviewsBuilder)
        self.axis = .horizontal
    }
}