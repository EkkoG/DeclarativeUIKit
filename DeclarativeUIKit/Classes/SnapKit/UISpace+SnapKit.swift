import UIKit
import SnapKit

extension UISpace {
    public convenience init(height: CGFloat) {
        self.init()
        self.S.height(height)
    }

    public convenience init(width: CGFloat) {
        self.init()
        self.S.width(width)
    }
}

extension SnapObject where Base: UISpace {

    @discardableResult
    func height(_ height: CGFloat) -> Self {
        self.makeConstraints { (make) in
            make.height.equalTo(height)
        }
        return self
    }

    @discardableResult
    func width(_ width: CGFloat) -> Self {
        self.makeConstraints { (make) in
            make.width.equalTo(width)
        }
        return self
    }
}