//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

extension UIStackView {
    public static func V(spacing: CGFloat = 0, alignment: Alignment = .fill, distribution: Distribution = .fill,
                         @BodyBuilder _ arrangedSubviewsBuilder: () -> BodyBuilderItemable) -> UIStackView {
        return UIStackView(axis: .vertical, spacing: spacing, alignment: alignment, distribution: distribution,
                           _arrangedSubviewsBuilder: arrangedSubviewsBuilder)
    }

    public static func H(spacing: CGFloat = 0, alignment: Alignment = .fill, distribution: Distribution = .fill,
                         @BodyBuilder _ arrangedSubviewsBuilder: () -> BodyBuilderItemable) -> UIStackView {
        return UIStackView(axis: .horizontal, spacing: spacing, alignment: alignment, distribution: distribution,
                           _arrangedSubviewsBuilder: arrangedSubviewsBuilder)
    }

    internal convenience init(axis: NSLayoutConstraint.Axis = .horizontal, spacing: CGFloat = 0,
                              alignment: Alignment = .fill, distribution: Distribution = .fill,
                              @BodyBuilder _arrangedSubviewsBuilder: () -> BodyBuilderItemable) {
        self.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        addArranged(item: _arrangedSubviewsBuilder())
    }

    private func _addArranged(_ view: UIView) {
        self.addArrangedSubview(view)
        view.applyPendingAutoLayout()

        if #available(iOS 11.0, *) {
            if let customSpacing = view.customSpacing {
                self.setCustomSpacing(customSpacing, after: view)
            }
        }
    }

    public func addArranged(item: [BodyBuilderItemable]) {
        item.forEach { addArranged(item: $0) }
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
