import UIKit
import SnapKit

extension UISpace {
    @discardableResult
    public func height(_ height: CGFloat) -> Self {
        self.makeConstraints { (make) in
            make.height.equalTo(height)
        }
        return self
    }

    @discardableResult
    public func width(_ width: CGFloat) -> Self {
        self.makeConstraints { (make) in
            make.width.equalTo(width)
        }
        return self
    }
}