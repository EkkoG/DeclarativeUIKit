//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

extension UIStackView {
    public static func V(@BodyBuilder _ arrangedSubviewsBuilder: () -> BodyBuilderItemable) -> UIStackView {
        let stackView = UIStackView.init(_arrangedSubviewsBuilder: arrangedSubviewsBuilder)
        stackView.axis = .vertical
        return stackView
    }

    public static func H(@BodyBuilder _ arrangedSubviewsBuilder: () -> BodyBuilderItemable) -> UIStackView {
        let stackView = UIStackView.init(_arrangedSubviewsBuilder: arrangedSubviewsBuilder)
        stackView.axis = .horizontal
        return stackView
    }

    internal convenience init(@BodyBuilder _arrangedSubviewsBuilder: () -> BodyBuilderItemable) {
        self.init(frame: .zero)
        addArranged(item: _arrangedSubviewsBuilder())
    }

    private func _addArranged(_ view: UIView) {
        self.addArrangedSubview(view)
        view.autolayoutBuilder?(view)

        if #available(iOS 11.0, *) {
            if let customSpacing = view.customSpacing {
                self.setCustomSpacing(customSpacing, after: view)
            }
        } else {
            // Fallback on earlier versions
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
