import UIKit
import SnapKit

extension UISpace {
    public convenience init(height: CGFloat) {
        self.init()
        layout { $0.height.equalTo(height) }
    }

    public convenience init(width: CGFloat) {
        self.init()
        layout { $0.width.equalTo(width) }
    }
}
