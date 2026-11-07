import UIKit

extension UIButton {
    public convenience init(_ title: String, type: UIButton.ButtonType = .system) {
        self.init(type: type)
        setTitle(title, for: .normal)
    }
}
