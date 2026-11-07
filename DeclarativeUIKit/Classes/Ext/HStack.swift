//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

open class HStack: UIStackView {
    public convenience init(spacing: CGFloat = 0, alignment: Alignment = .fill, distribution: Distribution = .fill,
                            @BodyBuilder arrangedSubviewsBuilder: () -> [UIView]) {
        self.init(axis: .horizontal, spacing: spacing, alignment: alignment, distribution: distribution,
                  _arrangedSubviewsBuilder: arrangedSubviewsBuilder)
    }
}
