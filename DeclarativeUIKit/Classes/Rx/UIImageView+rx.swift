import UIKit
import RxSwift

extension RxObject where Base: UIImageView {
    @discardableResult
    public func image(_ observable: Observable<UIImage?>) -> Self {
        base.bind(observable, to: \.image)
        return self
    }
}
