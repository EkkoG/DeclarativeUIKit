import UIKit
import Combine

@available(iOS 13.0, *)
extension Applyable where Self: UIView {
    @discardableResult
    public func backgroundColor<P: Publisher>(_ publisher: P) -> Self where P.Output == UIColor, P.Failure == Never {
        return bind(publisher, to: \.backgroundColor)
    }

    @discardableResult
    public func alpha<P: Publisher>(_ publisher: P) -> Self where P.Output == CGFloat, P.Failure == Never {
        return bind(publisher, to: \.alpha)
    }

    @discardableResult
    public func isHidden<P: Publisher>(_ publisher: P) -> Self where P.Output == Bool, P.Failure == Never {
        return bind(publisher, to: \.isHidden)
    }

    @discardableResult
    public func isUserInteractionEnabled<P: Publisher>(_ publisher: P) -> Self where P.Output == Bool, P.Failure == Never {
        return bind(publisher, to: \.isUserInteractionEnabled)
    }
}
