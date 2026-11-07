import UIKit
import RxSwift

extension RxObject where Base: UIControl {
    @discardableResult
    public func isEnabled(_ observable: Observable<Bool>) -> Self {
        base.bind(observable, to: \.isEnabled)
        return self
    }

    @discardableResult
    public func isSelected(_ observable: Observable<Bool>) -> Self {
        base.bind(observable, to: \.isSelected)
        return self
    }

    @discardableResult
    public func isHighlighted(_ observable: Observable<Bool>) -> Self {
        base.bind(observable, to: \.isHighlighted)
        return self
    }
}
