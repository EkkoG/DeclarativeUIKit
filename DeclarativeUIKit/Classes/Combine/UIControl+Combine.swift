//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import Combine

@available(iOS 13.0, *)
extension UIControl {
    @discardableResult
    public func isEnabled(_ isEnabled: Published<Bool>.Publisher) -> Self {
        isEnabled.sink() { s in
            self.isEnabled = s
        }
        return self
    }

    @discardableResult
    public func isSelected(_ isSelected: Published<Bool>.Publisher) -> Self {
        isSelected.sink() { s in
            self.isSelected = s
        }
        return self
    }

    @discardableResult
    public func isHighlighted(_ isHighlighted: Published<Bool>.Publisher) -> Self {
        isHighlighted.sink() { s in
            self.isHighlighted = s
        }
        return self
    }
}

