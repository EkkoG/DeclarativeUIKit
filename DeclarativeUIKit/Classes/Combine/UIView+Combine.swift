//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import Combine

@available(iOS 13.0, *)
extension UIView {
    @discardableResult
    public func backgroundColor(_ color: Published<UIColor>.Publisher) -> Self {
        color.sink() { s in
            self.backgroundColor = s ?? .clear
        }
        return self
    }

    @discardableResult
    public func alpha(_ alpha: Published<CGFloat>.Publisher) -> Self {
        alpha.sink() { s in
            self.alpha = s ?? 0
        }
        return self
    }

    @discardableResult
    public func isHidden(_ isHidden: Published<Bool>.Publisher) -> Self {
        isHidden.sink() { s in
            self.isHidden = s ?? true
        }
        return self
    }

    @discardableResult
    public func isUserInteractionEnabled(_ isUserInteractionEnabled: Published<Bool>.Publisher) -> Self {
        isUserInteractionEnabled.sink() { s in
            self.isUserInteractionEnabled = s ?? true
        }
        return self
    }
}
