import UIKit
import SnapKit

extension SnapObject where Base: UIView {
    @discardableResult
    public func makeConstraints(_ closure: @escaping (ConstraintMaker) -> Void) -> Self {
        base.applyAutoLayout { view in
            view.snp.makeConstraints { (make) in
                closure(make)
            }
        }
        return self
    }
}