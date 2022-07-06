//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import RxSwift
import RxCocoa

extension RxObject where Base: UIControl {
    @discardableResult
    public func isEnabled(_ isEnabled: Observable<Bool>) -> Self {
        isEnabled.subscribe { s in
            base.isEnabled = s.element ?? true
        }
        return self
    }

    @discardableResult
    public func isSelected(_ isSelected: Observable<Bool>) -> Self {
        isSelected.subscribe { s in
            base.isSelected = s.element ?? false
        }
        return self
    }

    @discardableResult
    public func isHighlighted(_ isHighlighted: Observable<Bool>) -> Self {
        isHighlighted.subscribe { s in
            base.isHighlighted = s.element ?? false
        }
        return self
    }
}

