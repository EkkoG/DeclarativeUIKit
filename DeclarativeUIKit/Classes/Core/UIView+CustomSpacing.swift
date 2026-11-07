//
// Created by Kevin Guo on 2022/7/6.
//

import UIKit

@available(iOS 11.0, *)
extension UIView {

    private struct AssociatedKeys {
        static var customSpacing: UInt8 = 0
    }
    var customSpacing: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customSpacing) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customSpacing, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    @discardableResult
    public func spacingAfterSelf(_ customSpacing: CGFloat?) -> Self {
        self.customSpacing = customSpacing
        return self
    }
}
