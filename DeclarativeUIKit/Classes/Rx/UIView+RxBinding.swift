import UIKit
import RxSwift

private final class RxBindings {
    var subscriptions: [AnyHashable: SerialDisposable] = [:]

    deinit {
        subscriptions.values.forEach { $0.dispose() }
    }
}

private var rxBindingsKey: UInt8 = 0

func bindRx<Value, View: UIView>(_ observable: Observable<Value>, to view: View, key: AnyHashable,
                                setValue: @escaping (View, Value) -> Void) {
    precondition(Thread.isMainThread, "Configure UI bindings on the main thread")
    let bindings: RxBindings
    if let stored = objc_getAssociatedObject(view, &rxBindingsKey) as? RxBindings {
        bindings = stored
    } else {
        bindings = RxBindings()
        objc_setAssociatedObject(view, &rxBindingsKey, bindings, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    // Disposal and synchronous emissions can both cause another binding.
    let subscription = SerialDisposable()
    let previous = bindings.subscriptions.updateValue(subscription, forKey: key)
    previous?.dispose()
    guard !subscription.isDisposed else { return }
    subscription.disposable = observable
        .observe(on: MainScheduler.instance)
        .subscribe(onNext: { [weak view, weak subscription] value in
            guard let view = view, let subscription = subscription, !subscription.isDisposed else { return }
            setValue(view, value)
        }, onError: { _ in })
}

extension ViewConfigurable where Self: UIView {
    @discardableResult
    public func bind<Value>(_ observable: Observable<Value>, to keyPath: ReferenceWritableKeyPath<Self, Value>) -> Self {
        bindRx(observable, to: self, key: keyPath) { view, value in
            view[keyPath: keyPath] = value
        }
        return self
    }

    @discardableResult
    public func bind<Value>(_ observable: Observable<Value>, to keyPath: ReferenceWritableKeyPath<Self, Value?>) -> Self {
        return bind(observable.map(Optional.some), to: keyPath)
    }
}
