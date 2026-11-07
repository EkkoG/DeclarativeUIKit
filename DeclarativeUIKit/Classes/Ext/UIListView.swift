//
// Created by Kevin Guo on 2022/7/21.
//

import UIKit
#if canImport(SnapKit)
import SnapKit

public class UIListView: UIScrollView {
    public convenience init(with direction: NSLayoutConstraint.Axis, @BodyBuilder arrangedSubviewsBuilder: () -> [UIView]) {
        self.init {
            UIStackView(axis: direction, _arrangedSubviewsBuilder: arrangedSubviewsBuilder).onMount { view in
                view.snp.makeConstraints { maker in
                    maker.edges.equalToSuperview()
                }
            }
        }
    }
}

#endif
