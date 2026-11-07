import UIKit
import SnapKit

extension UIView {
    @discardableResult
    public func layout(_ closure: @escaping (ConstraintMaker) -> Void) -> Self {
        return onMount { view in
            view.snp.makeConstraints(closure)
        }
    }
}
