//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import RxSwift
import RxCocoa

extension UIImageView {
    @discardableResult
    public func image(_ image: Observable<UIImage?>) -> Self {
        image.subscribe { s in
            self.image = s.element ?? nil
        }
        return self
    }
}
