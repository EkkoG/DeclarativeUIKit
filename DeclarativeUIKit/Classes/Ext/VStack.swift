//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

open class VStack: UIStackView {
    public convenience init(spacing: CGFloat = 0, alignment: Alignment = .fill, distribution: Distribution = .fill,
                            @BodyBuilder arrangedSubviewsBuilder: () -> BodyBuilderItemable) {
        self.init(axis: .vertical, spacing: spacing, alignment: alignment, distribution: distribution,
                  _arrangedSubviewsBuilder: arrangedSubviewsBuilder)
    }
}
