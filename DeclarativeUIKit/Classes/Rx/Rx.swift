//
// Created by Kevin Guo on 2022/7/6.
//

public protocol Rx {
    associatedtype S
    var R: RxObject<S> { get }
}

public extension Rx {
    public var R: RxObject<Self> {
        return RxObject(self)
    }
}

public struct RxObject<Base> {
    public let base: Base

    init(_ base: Base) {
        self.base = base
    }
}


extension UIView: Rx {}
