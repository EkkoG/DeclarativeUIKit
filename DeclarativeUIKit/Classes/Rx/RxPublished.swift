import Foundation
import RxSwift
import RxCocoa

// NOTE
// 参考実装
// https://www.swiftbysundell.com/articles/property-wrappers-in-swift/
//
// Exclusively Enforcement問題
// (購読の仕方によって wrappedValue.setter 内で getter が呼ばれるケースがある)
// 回避のため、Property Wrapperをstructではなくclassで定義している
// (Computed Propertyに対してExclusively Enforcementが必要なのか疑問だが...)
//
// https://swift.org/blog/swift-5-exclusivity

/// Combineの@Publishedに相当するProperty Wrapper
/// Usage:
///   @RxProperty private(set) var value = 0
///
///   value: Int型
///   $value: BehaviorRelay<Int>
///   として参照できる
@propertyWrapper
public final class RxPublished<Value> {
    public var projectedValue: Observable<Value> { relay.asObservable() }
    public var wrappedValue: Value {
        get { relay.value }
        set { relay.accept(newValue) }
    }

    private let relay: BehaviorRelay<Value>

    public init(wrappedValue: Value) {
        self.relay = .init(value: wrappedValue)
    }
}

/// Combineの@Publishedに相当するProperty Wrapper
/// @RxPropertyとの違いは、projectedValueの型がObservable<Value>なので
/// メインスレッドでの購読が保証されている
@propertyWrapper
final public class RxUIPublished<Value> {
    public var projectedValue: Observable<Value> { relay.asDriver().asObservable() }
    public var wrappedValue: Value {
        get { relay.value }
        set { relay.accept(newValue) }
    }

    private let relay: BehaviorRelay<Value>

    public init(wrappedValue: Value) {
        self.relay = .init(value: wrappedValue)
    }
}

extension Observable {
    /// ストリームの値をobject[keyPath: keyPath]に代入する
    func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Element>, on object: Root) -> Disposable {
        return bind(onNext: { object[keyPath: keyPath] = $0 })
    }
}

extension SharedSequenceConvertibleType where Self.SharingStrategy == RxCocoa.DriverSharingStrategy {
    /// ストリームの値をobject[keyPath: keyPath]に代入する
    func assign<Root>(to keyPath: ReferenceWritableKeyPath<Root, Element>, on object: Root) -> Disposable {
        return drive(onNext: { object[keyPath: keyPath] = $0 })
    }
}
