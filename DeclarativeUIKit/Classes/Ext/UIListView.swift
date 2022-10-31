//
// Created by Kevin Guo on 2022/7/21.
//

import UIKit
#if canImport(SnapKit)
import SnapKit

public class UIListView: UIScrollView {
    public convenience init(with direction: NSLayoutConstraint.Axis, @BodyBuilder arrangedSubviewsBuilder: () -> BodyBuilderItemable) {
        self.init {
            UIStackView.init(_arrangedSubviewsBuilder: arrangedSubviewsBuilder).apply { view in
                view.axis = direction
            }.applyAutoLayout { view in
                view.snp.makeConstraints { maker in
                    maker.edges.equalToSuperview()
                }
            }
        }
    }
}

#endif
