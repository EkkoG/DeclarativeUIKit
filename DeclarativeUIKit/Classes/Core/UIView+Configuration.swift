import UIKit

// A protocol lets typed callbacks and key paths use Self in parameter positions.
public protocol ViewConfigurable: AnyObject {}
extension UIView: ViewConfigurable {}

extension ViewConfigurable where Self: UIView {
    @discardableResult
    public func set<Value>(_ keyPath: ReferenceWritableKeyPath<Self, Value>, to value: Value) -> Self {
        self[keyPath: keyPath] = value
        return self
    }
}
