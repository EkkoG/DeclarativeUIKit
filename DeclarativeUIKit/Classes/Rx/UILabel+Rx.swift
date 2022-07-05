//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import RxSwift
import RxCocoa

extension UILabel {
    @discardableResult
    public func text(_ text: Observable<String>) -> Self {
        text.subscribe { s in
            self.text = s.element ?? ""
        }
        return self
    }

    @discardableResult
    public func textColor(_ textColor: Observable<UIColor>) -> Self {
        textColor.subscribe { s in
            self.textColor = s.element ?? .clear
        }
        return self
    }

    @discardableResult
    public func font(_ font: Observable<UIFont>) -> Self {
        font.subscribe { s in
            self.font = s.element ?? .systemFont(ofSize: 0)
        }
        return self
    }

    @discardableResult
    public func textAlignment(_ textAlignment: Observable<NSTextAlignment>) -> Self {
        textAlignment.subscribe { s in
            self.textAlignment = s.element ?? .left
        }
        return self
    }

    @discardableResult
    public func numberOfLines(_ numberOfLines: Observable<Int>) -> Self {
        numberOfLines.subscribe { s in
            self.numberOfLines = s.element ?? 0
        }
        return self
    }

    @discardableResult
    public func lineBreakMode(_ lineBreakMode: Observable<NSLineBreakMode>) -> Self {
        lineBreakMode.subscribe { s in
            self.lineBreakMode = s.element ?? .byWordWrapping
        }
        return self
    }

    @discardableResult
    public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Observable<Bool>) -> Self {
        adjustsFontSizeToFitWidth.subscribe { s in
            self.adjustsFontSizeToFitWidth = s.element ?? false
        }
        return self
    }
}