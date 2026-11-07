import UIKit
import Combine

@available(iOS 13.0, *)
extension Applyable where Self: UIImageView {
    @discardableResult
    public func image<P: Publisher>(_ publisher: P) -> Self where P.Output == UIImage?, P.Failure == Never {
        return bind(publisher, to: \.image)
    }
}
