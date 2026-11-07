import UIKit
import RxSwift

extension RxObject where Base: UIButton {
    @discardableResult
    public func title(_ observable: Observable<String>, for state: UIControl.State = .normal) -> Self {
        bindRx(observable, to: base, key: "button.title.\(state.rawValue)") { button, value in
            button.setTitle(value, for: state)
        }
        return self
    }

    @discardableResult
    public func titleColor(_ observable: Observable<UIColor>, for state: UIControl.State = .normal) -> Self {
        bindRx(observable, to: base, key: "button.titleColor.\(state.rawValue)") { button, value in
            button.setTitleColor(value, for: state)
        }
        return self
    }

    @discardableResult
    public func image(_ observable: Observable<UIImage>, for state: UIControl.State = .normal) -> Self {
        bindRx(observable, to: base, key: "button.image.\(state.rawValue)") { button, value in
            button.setImage(value, for: state)
        }
        return self
    }

    @discardableResult
    public func backgroundImage(_ observable: Observable<UIImage>, for state: UIControl.State = .normal) -> Self {
        bindRx(observable, to: base, key: "button.backgroundImage.\(state.rawValue)") { button, value in
            button.setBackgroundImage(value, for: state)
        }
        return self
    }

    @discardableResult
    public func attributedTitle(_ observable: Observable<NSAttributedString>, for state: UIControl.State = .normal) -> Self {
        bindRx(observable, to: base, key: "button.attributedTitle.\(state.rawValue)") { button, value in
            button.setAttributedTitle(value, for: state)
        }
        return self
    }

    @discardableResult
    public func contentEdgeInsets(_ observable: Observable<UIEdgeInsets>) -> Self {
        base.bind(observable, to: \.contentEdgeInsets)
        return self
    }
}
