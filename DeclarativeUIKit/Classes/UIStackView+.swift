//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

extension UIStackView {
    private func _addArranged(_ view: UIView) {
        self.addArrangedSubview(view)
        if let builder = view.autolayoutBuilder {
            builder(view)
        }
    }

    public func addArranged(item: BodyBuilderItemable) {
        switch item.bodyBuilderItem {
        case .single(let view):
            _addArranged(view)
        case .multiple(let views):
            views.forEach { addArranged(item: $0) }
        case .nested(let items):
            items.forEach { addArranged(item: $0) }
        case .none:
            break
        }
    }
}
