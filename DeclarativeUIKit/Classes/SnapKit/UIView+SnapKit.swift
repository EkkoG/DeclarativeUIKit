import UIKit
import SnapKit

extension SnapObject where Base: UIView {
    @discardableResult
    public func makeConstraints(_ closure: @escaping (ConstraintMaker) -> Void) -> Self {
        base.layout(closure)
        return self
    }
}

extension UIView {
    @discardableResult
    public func layout(_ closure: @escaping (ConstraintMaker) -> Void) -> Self {
        return applyAutoLayout { view in
            view.snp.makeConstraints(closure)
        }
    }
}
