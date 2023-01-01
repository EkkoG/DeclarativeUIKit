//
// Created by Kevin Guo on 2022/7/6.
//


public protocol Snap {
    associatedtype S
    var S: SnapObject<S> { get }
}

public extension Snap {
    var S: SnapObject<Self> {
        return SnapObject(self)
    }
}

public struct SnapObject<Base> {
    public let base: Base

    init(_ base: Base) {
        self.base = base
    }
}


extension UIView: Snap {}

