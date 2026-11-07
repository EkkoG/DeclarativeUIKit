//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

extension UIStackView {
    public static func V(spacing: CGFloat = 0, alignment: Alignment = .fill, distribution: Distribution = .fill,
                         @BodyBuilder _ arrangedSubviewsBuilder: () -> [UIView]) -> UIStackView {
        return UIStackView(axis: .vertical, spacing: spacing, alignment: alignment, distribution: distribution,
                           _arrangedSubviewsBuilder: arrangedSubviewsBuilder)
    }

    public static func H(spacing: CGFloat = 0, alignment: Alignment = .fill, distribution: Distribution = .fill,
                         @BodyBuilder _ arrangedSubviewsBuilder: () -> [UIView]) -> UIStackView {
        return UIStackView(axis: .horizontal, spacing: spacing, alignment: alignment, distribution: distribution,
                           _arrangedSubviewsBuilder: arrangedSubviewsBuilder)
    }

    internal convenience init(axis: NSLayoutConstraint.Axis = .horizontal, spacing: CGFloat = 0,
                              alignment: Alignment = .fill, distribution: Distribution = .fill,
                              @BodyBuilder _arrangedSubviewsBuilder: () -> [UIView]) {
        self.init(frame: .zero)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
        addArranged(_arrangedSubviewsBuilder())
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

    public func addArranged(_ views: [UIView]) {
        views.forEach { _addArranged($0) }
    }
}
