//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import Combine

@available(iOS 13.0, *)
extension UIImageView {
    @discardableResult
    public func image(_ image: Published<UIImage?>.Publisher) -> Self {
        image.sink() { s in
            self.image = s
        }
        return self
    }
}
