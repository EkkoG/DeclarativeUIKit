//
// Created by Kevin Guo on 2022/7/4.
//

import UIKit

public protocol Applyable: AnyObject {}
extension Applyable {
    @discardableResult
    public func apply(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
}

extension UIView: Applyable {}