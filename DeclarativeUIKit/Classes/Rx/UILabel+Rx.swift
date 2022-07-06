//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import RxSwift
import RxCocoa

extension RxObject where Base: UILabel {
    @discardableResult
    public func text(_ text: Observable<String>) -> Self {
        text.subscribe { s in
            base.text = s.element ?? ""
        }
        return self
    }

    @discardableResult
    public func textColor(_ textColor: Observable<UIColor>) -> Self {
        textColor.subscribe { s in
            base.textColor = s.element ?? .clear
        }
        return self
    }

    @discardableResult
    public func font(_ font: Observable<UIFont>) -> Self {
        font.subscribe { s in
            base.font = s.element ?? .systemFont(ofSize: 0)
        }
        return self
    }

    @discardableResult
    public func textAlignment(_ textAlignment: Observable<NSTextAlignment>) -> Self {
        textAlignment.subscribe { s in
            base.textAlignment = s.element ?? .left
        }
        return self
    }

    @discardableResult
    public func numberOfLines(_ numberOfLines: Observable<Int>) -> Self {
        numberOfLines.subscribe { s in
            base.numberOfLines = s.element ?? 0
        }
        return self
    }

    @discardableResult
    public func lineBreakMode(_ lineBreakMode: Observable<NSLineBreakMode>) -> Self {
        lineBreakMode.subscribe { s in
            base.lineBreakMode = s.element ?? .byWordWrapping
        }
        return self
    }

    @discardableResult
    public func adjustsFontSizeToFitWidth(_ adjustsFontSizeToFitWidth: Observable<Bool>) -> Self {
        adjustsFontSizeToFitWidth.subscribe { s in
            base.adjustsFontSizeToFitWidth = s.element ?? false
        }
        return self
    }
}