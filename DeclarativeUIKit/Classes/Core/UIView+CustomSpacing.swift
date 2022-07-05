//
// Created by Kevin Guo on 2022/7/6.
//

import UIKit

@available(iOS 11.0, *)
extension UIView {

    private struct AssociatedKeys {
        static var customSpacing = "customSpacing"
    }
    var customSpacing: CGFloat? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.customSpacing) as? CGFloat
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.customSpacing, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
        }
    }
    @discardableResult
    public func customSpacing(_ customSpacing: CGFloat?) -> Self {
        self.customSpacing = customSpacing
        return self
    }
}
