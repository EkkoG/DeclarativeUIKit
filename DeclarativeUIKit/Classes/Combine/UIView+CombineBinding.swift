import UIKit
import Combine

@available(iOS 13.0, *)
private final class CombineBindings {
    var subscriptions: [AnyHashable: AnyCancellable] = [:]
}

private var combineBindingsKey: UInt8 = 0

@available(iOS 13.0, *)
func bindCombine<P: Publisher, View: UIView>(_ publisher: P, to view: View, key: AnyHashable,
                                           setValue: @escaping (View, P.Output) -> Void) where P.Failure == Never {
    precondition(Thread.isMainThread, "Configure UI bindings on the main thread")
    let bindings: CombineBindings
    if let stored = objc_getAssociatedObject(view, &combineBindingsKey) as? CombineBindings {
        bindings = stored
    } else {
        bindings = CombineBindings()
        objc_setAssociatedObject(view, &combineBindingsKey, bindings, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    let subscriber = Subscribers.Sink<P.Output, Never>(receiveCompletion: { _ in }, receiveValue: { [weak view] value in
        guard let view = view else { return }
        setValue(view, value)
    })
    // Store the receiver before cancellation or subscription callbacks can bind again.
    let subscription = AnyCancellable(subscriber)
    let previous = bindings.subscriptions.updateValue(subscription, forKey: key)
    previous?.cancel()
    guard bindings.subscriptions[key] === subscription else { return }
    publisher.receive(on: DispatchQueue.main).subscribe(subscriber)
    // Sink can receive its subscription after a reentrant cancellation.
    if bindings.subscriptions[key] !== subscription {
        subscriber.cancel()
    }
}

@available(iOS 13.0, *)
extension Applyable where Self: UIView {
    @discardableResult
    public func bind<P: Publisher>(_ publisher: P, to keyPath: ReferenceWritableKeyPath<Self, P.Output>) -> Self
        where P.Failure == Never {
        bindCombine(publisher, to: self, key: keyPath) { view, value in
            view[keyPath: keyPath] = value
        }
        return self
    }

    @discardableResult
    public func bind<P: Publisher>(_ publisher: P, to keyPath: ReferenceWritableKeyPath<Self, P.Output?>) -> Self
        where P.Failure == Never {
        return bind(publisher.map(Optional.some), to: keyPath)
    }
}
