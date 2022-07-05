//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import Combine

@available(iOS 13.0, *)
extension UILabel {
    @discardableResult
    public func text(_ text: Published<String>.Publisher) -> Self {
        let _ = text.sink() { s in
            self.text = s
        }
        return self
    }

    @discardableResult
    public func textColor(_ textColor: Published<UIColor>.Publisher) -> Self {
        textColor.sink() { s in
            self.textColor = s
        }
        return self
    }

    @discardableResult
    public func font(_ font: Published<UIFont>.Publisher) -> Self {
        font.sink() { s in
            self.font = s
        }
        return self
    }

    @discardableResult
    public func textAlignment(_ textAlignment: Published<NSTextAlignment>.Publisher) -> Self {
        textAlignment.sink() { s in
            self.textAlignment = s
        }
        return self
    }

    @discardableResult
    public func numberOfLines(_ numberOfLines: Published<Int>.Publisher) -> Self {
        numberOfLines.sink() { s in
            self.numberOfLines = s
        }
        return self
    }

    @discardableResult
    public func lineBreakMode(_ lineBreakMode: Published<NSLineBreakMode>.Publisher) -> Self {
        lineBreakMode.sink() { s in
            self.lineBreakMode = s
        }
        return self
    }

    @discardableResult
    public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Published<Bool>.Publisher) -> Self {
        adjustsFontSizeToFitWidth.sink() { s in
            self.adjustsFontSizeToFitWidth = s
        }
        return self
    }
}