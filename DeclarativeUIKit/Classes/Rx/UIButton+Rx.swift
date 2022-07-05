//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import RxSwift
import RxCocoa

extension UIButton {
    @discardableResult
    public func title(_ title: Observable<String>, for state: UIControl.State = .normal) -> Self {
        title.subscribe { s in
            self.setTitle(s.element ?? "", for: state)
        }
        return self
    }

    @discardableResult
    public func titleColor(_ titleColor: Observable<UIColor>, for state: UIControl.State = .normal) -> Self {
        titleColor.subscribe { s in
            self.setTitleColor(s.element ?? .clear, for: state)
        }
        return self
    }

    @discardableResult
    public func image(_ image: Observable<UIImage>, for state: UIControl.State = .normal) -> Self {
        image.subscribe { s in
            self.setImage(s.element, for: state)
        }
        return self
    }

    @discardableResult
    public func backgroundImage(_ backgroundImage: Observable<UIImage>, for state: UIControl.State = .normal) -> Self {
        backgroundImage.subscribe { s in
            self.setBackgroundImage(s.element, for: state)
        }
        return self
    }

    @discardableResult
    public func attributedTitle(_ attributedTitle: Observable<NSAttributedString>, for state: UIControl.State = .normal) -> Self {
        attributedTitle.subscribe { s in
            self.setAttributedTitle(s.element, for: state)
        }
        return self
    }

    @discardableResult
    public func contentEdgeInsets(_ contentEdgeInsets: Observable<UIEdgeInsets>) -> Self {
        contentEdgeInsets.subscribe { s in
            self.contentEdgeInsets = s.element ?? .zero
        }
        return self
    }
}
