//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import RxSwift
import RxCocoa

extension UIControl {
    @discardableResult
    public func isEnabled(_ isEnabled: Observable<Bool>) -> Self {
        isEnabled.subscribe { s in
            self.isEnabled = s.element ?? true
        }
        return self
    }

    @discardableResult
    public func isSelected(_ isSelected: Observable<Bool>) -> Self {
        isSelected.subscribe { s in
            self.isSelected = s.element ?? false
        }
        return self
    }

    @discardableResult
    public func isHighlighted(_ isHighlighted: Observable<Bool>) -> Self {
        isHighlighted.subscribe { s in
            self.isHighlighted = s.element ?? false
        }
        return self
    }
}

