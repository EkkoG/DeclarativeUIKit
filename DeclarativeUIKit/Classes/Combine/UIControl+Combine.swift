import UIKit
import Combine

@available(iOS 13.0, *)
extension Applyable where Self: UIControl {
    @discardableResult
    public func isEnabled<P: Publisher>(_ publisher: P) -> Self where P.Output == Bool, P.Failure == Never {
        return bind(publisher, to: \.isEnabled)
    }

    @discardableResult
    public func isSelected<P: Publisher>(_ publisher: P) -> Self where P.Output == Bool, P.Failure == Never {
        return bind(publisher, to: \.isSelected)
    }

    @discardableResult
    public func isHighlighted<P: Publisher>(_ publisher: P) -> Self where P.Output == Bool, P.Failure == Never {
        return bind(publisher, to: \.isHighlighted)
    }
}
