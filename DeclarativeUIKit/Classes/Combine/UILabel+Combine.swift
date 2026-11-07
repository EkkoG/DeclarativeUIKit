import UIKit
import Combine

@available(iOS 13.0, *)
extension Applyable where Self: UILabel {
    @discardableResult
    public func text<P: Publisher>(_ publisher: P) -> Self where P.Output == String, P.Failure == Never {
        return bind(publisher, to: \.text)
    }

    @discardableResult
    public func textColor<P: Publisher>(_ publisher: P) -> Self where P.Output == UIColor, P.Failure == Never {
        return bind(publisher, to: \.textColor)
    }

    @discardableResult
    public func font<P: Publisher>(_ publisher: P) -> Self where P.Output == UIFont, P.Failure == Never {
        return bind(publisher, to: \.font)
    }

    @discardableResult
    public func textAlignment<P: Publisher>(_ publisher: P) -> Self where P.Output == NSTextAlignment, P.Failure == Never {
        return bind(publisher, to: \.textAlignment)
    }

    @discardableResult
    public func numberOfLines<P: Publisher>(_ publisher: P) -> Self where P.Output == Int, P.Failure == Never {
        return bind(publisher, to: \.numberOfLines)
    }

    @discardableResult
    public func lineBreakMode<P: Publisher>(_ publisher: P) -> Self where P.Output == NSLineBreakMode, P.Failure == Never {
        return bind(publisher, to: \.lineBreakMode)
    }

    @discardableResult
    public func adjustsFontSizeToFitWidth<P: Publisher>(_ publisher: P) -> Self where P.Output == Bool, P.Failure == Never {
        return bind(publisher, to: \.adjustsFontSizeToFitWidth)
    }
}
