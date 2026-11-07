import UIKit

extension UILabel {
    public convenience init(_ text: String) {
        self.init(frame: .zero)
        self.text = text
    }
}
