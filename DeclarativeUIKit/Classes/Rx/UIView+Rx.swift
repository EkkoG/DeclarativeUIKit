import UIKit
import RxSwift

extension RxObject where Base: UIView {
    @discardableResult
    public func backgroundColor(_ observable: Observable<UIColor>) -> Self {
        base.bind(observable, to: \.backgroundColor)
        return self
    }

    @discardableResult
    public func alpha(_ observable: Observable<CGFloat>) -> Self {
        base.bind(observable, to: \.alpha)
        return self
    }

    @discardableResult
    public func isHidden(_ observable: Observable<Bool>) -> Self {
        base.bind(observable, to: \.isHidden)
        return self
    }

    @discardableResult
    public func isUserInteractionEnabled(_ observable: Observable<Bool>) -> Self {
        base.bind(observable, to: \.isUserInteractionEnabled)
        return self
    }
}
