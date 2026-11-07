import UIKit
import RxSwift

extension RxObject where Base: UILabel {
    @discardableResult
    public func text(_ observable: Observable<String>) -> Self {
        base.bind(observable, to: \.text)
        return self
    }

    @discardableResult
    public func textColor(_ observable: Observable<UIColor>) -> Self {
        base.bind(observable, to: \.textColor)
        return self
    }

    @discardableResult
    public func font(_ observable: Observable<UIFont>) -> Self {
        base.bind(observable, to: \.font)
        return self
    }

    @discardableResult
    public func textAlignment(_ observable: Observable<NSTextAlignment>) -> Self {
        base.bind(observable, to: \.textAlignment)
        return self
    }

    @discardableResult
    public func numberOfLines(_ observable: Observable<Int>) -> Self {
        base.bind(observable, to: \.numberOfLines)
        return self
    }

    @discardableResult
    public func lineBreakMode(_ observable: Observable<NSLineBreakMode>) -> Self {
        base.bind(observable, to: \.lineBreakMode)
        return self
    }

    @discardableResult
    public func adjustsFontSizeToFitWidth(_ observable: Observable<Bool>) -> Self {
        base.bind(observable, to: \.adjustsFontSizeToFitWidth)
        return self
    }
}
