//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import RxSwift
import RxCocoa

extension UIView {
    @discardableResult
    public func backgroundColor(_ color: Observable<UIColor>) -> Self {
        color.subscribe { s in
            self.backgroundColor = s.element ?? .clear
        }
        return self
    }

    @discardableResult
    public func alpha(_ alpha: Observable<CGFloat>) -> Self {
        alpha.subscribe { s in
            self.alpha = s.element ?? 0
        }
        return self
    }

    @discardableResult
    public func isHidden(_ isHidden: Observable<Bool>) -> Self {
        isHidden.subscribe { s in
            self.isHidden = s.element ?? true
        }
        return self
    }

    @discardableResult
    public func isUserInteractionEnabled(_ isUserInteractionEnabled: Observable<Bool>) -> Self {
        isUserInteractionEnabled.subscribe { s in
            self.isUserInteractionEnabled = s.element ?? true
        }
        return self
    }
}
