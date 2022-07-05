//
// Created by Kevin Guo on 2022/7/5.
//

import UIKit
import Combine

@available(iOS 13.0, *)
extension UIButton {
    @discardableResult
    public func title(_ title: Published<String>.Publisher, for state: UIControl.State = .normal) -> Self {
        title.sink() { s in
            self.setTitle(s, for: state)
        }
        return self
    }

    @discardableResult
    public func titleColor(_ titleColor: Published<UIColor>.Publisher, for state: UIControl.State = .normal) -> Self {
        titleColor.sink() { s in
            self.setTitleColor(s, for: state)
        }
        return self
    }

    @discardableResult
    public func image(_ image: Published<UIImage>.Publisher, for state: UIControl.State = .normal) -> Self {
        image.sink() { s in
            self.setImage(s, for: state)
        }
        return self
    }

    @discardableResult
    public func backgroundImage(_ backgroundImage: Published<UIImage>.Publisher, for state: UIControl.State = .normal) -> Self {
        backgroundImage.sink() { s in
            self.setBackgroundImage(s, for: state)
        }
        return self
    }

    @discardableResult
    public func attributedTitle(_ attributedTitle: Published<NSAttributedString>.Publisher, for state: UIControl.State = .normal) -> Self {
        attributedTitle.sink() { s in
            self.setAttributedTitle(s, for: state)
        }
        return self
    }

    @discardableResult
    public func contentEdgeInsets(_ contentEdgeInsets: Published<UIEdgeInsets>.Publisher) -> Self {
        contentEdgeInsets.sink() { s in
            self.contentEdgeInsets = s
        }
        return self
    }
}
