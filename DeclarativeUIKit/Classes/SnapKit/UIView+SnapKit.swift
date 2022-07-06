import UIKit
import SnapKit

extension UIView {
    @discardableResult
    public func makeConstraints(_ closure: @escaping (ConstraintMaker) -> Void) -> Self {
        self.applyAutoLayout { view in
            view.snp.makeConstraints { (make) in
                closure(make)
            }
        }
        return self
    }
}