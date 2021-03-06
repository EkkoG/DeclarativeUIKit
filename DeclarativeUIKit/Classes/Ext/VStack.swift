//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

open class VStack: UIStackView {
    public convenience init(@BodyBuilder arrangedSubviewsBuilder: () -> BodyBuilderItemable) {
        self.init(_arrangedSubviewsBuilder: arrangedSubviewsBuilder)
        self.axis = .vertical
    }
}