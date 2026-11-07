import UIKit
import Combine

@available(iOS 13.0, *)
extension Applyable where Self: UIButton {
    @discardableResult
    public func title<P: Publisher>(_ publisher: P, for state: UIControl.State = .normal) -> Self
        where P.Output == String, P.Failure == Never {
        bindCombine(publisher, to: self, key: "button.title.\(state.rawValue)") { button, value in
            button.setTitle(value, for: state)
        }
        return self
    }

    @discardableResult
    public func titleColor<P: Publisher>(_ publisher: P, for state: UIControl.State = .normal) -> Self
        where P.Output == UIColor, P.Failure == Never {
        bindCombine(publisher, to: self, key: "button.titleColor.\(state.rawValue)") { button, value in
            button.setTitleColor(value, for: state)
        }
        return self
    }

    @discardableResult
    public func image<P: Publisher>(_ publisher: P, for state: UIControl.State = .normal) -> Self
        where P.Output == UIImage, P.Failure == Never {
        bindCombine(publisher, to: self, key: "button.image.\(state.rawValue)") { button, value in
            button.setImage(value, for: state)
        }
        return self
    }

    @discardableResult
    public func backgroundImage<P: Publisher>(_ publisher: P, for state: UIControl.State = .normal) -> Self
        where P.Output == UIImage, P.Failure == Never {
        bindCombine(publisher, to: self, key: "button.backgroundImage.\(state.rawValue)") { button, value in
            button.setBackgroundImage(value, for: state)
        }
        return self
    }

    @discardableResult
    public func attributedTitle<P: Publisher>(_ publisher: P, for state: UIControl.State = .normal) -> Self
        where P.Output == NSAttributedString, P.Failure == Never {
        bindCombine(publisher, to: self, key: "button.attributedTitle.\(state.rawValue)") { button, value in
            button.setAttributedTitle(value, for: state)
        }
        return self
    }

    @discardableResult
    public func contentEdgeInsets<P: Publisher>(_ publisher: P) -> Self
        where P.Output == UIEdgeInsets, P.Failure == Never {
        return bind(publisher, to: \.contentEdgeInsets)
    }
}
