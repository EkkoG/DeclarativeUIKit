//
// Created by Kevin Guo on 2022/7/3.
//

import Foundation

public protocol Assignable {}

public extension Assignable {
    @discardableResult
    func assign<T>(to variable: inout T) -> Self {
        if let casted = self as? T {
            variable = casted
        } else {
            preconditionFailure("Can't cast \(Self.self) to \(T.self)")
        }

        return self
    }
}

extension UIView: Assignable {}
extension Optional: Assignable where Wrapped: Assignable {}
