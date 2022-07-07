//
// Created by Kevin Guo on 2022/7/7.
//

import UIKit

#if canImport(RxSwift)
import RxSwift

extension ObservableType {
    public func __nwise(_ n: Int) -> Observable<[Element]> {
        assert(n > 1, "n must be greater than 1")
        return self
                .scan([]) { acc, item in Array((acc + [item]).suffix(n)) }
                .filter { $0.count == n }
    }
    public func __pairwise() -> Observable<(Element, Element)> {
        return self.__nwise(2)
                .map { ($0[0], $0[1]) }
    }
}

public protocol AnyIdentable {
    func identHash() -> Int
}

public protocol Identable: Hashable, AnyIdentable {
    associatedtype ID: Hashable

    typealias IDKey = KeyPath<Self, ID>

    static var idKey: IDKey { get }
}

extension Identable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self[keyPath: Self.idKey])
    }

    public func identHash() -> Int {
        self[keyPath: Self.idKey].hashValue
    }
}


extension Array {
    public struct DiffItem<V> {
        public let index: Int
        public let value: V
    }
    public struct DiffResult<T1, T2> {
        public let common: [(old: T1, new: T2)]
        public let removed: [DiffItem<T1>]
        public let inserted: [DiffItem<T2>]
        public let modified: [DiffItem<T2>]
        public init(common: [(T1, T2)] = [], removed: [DiffItem<T1>] = [], inserted: [DiffItem<T2>] = [], modified: [DiffItem<T2>] = []) {
            self.common = common
            self.removed = removed
            self.inserted = inserted
            self.modified = modified
        }
    }
    public func difference<T1: Hashable, T2: Hashable>(_ first: [T1], _ second: [T2], with compare: (Int,Int) -> Bool) -> DiffResult<T1, T2> {
        let combinations = first.compactMap { a in (a, second.first { b in compare(a.hashValue, b.hashValue) }) }
        let common = combinations.filter { $0.1 != nil }.compactMap { ($0.0, $0.1!) }
        var removed: [DiffItem<T1>] = combinations.filter { $0.1 == nil }.compactMap { a,_ in
            guard let index = first.firstIndex(where: { $0.hashValue == a.hashValue }) else { return nil }
            return DiffItem(index: index, value: a)
        }
        var inserted: [DiffItem<T2>] = second.filter { b in
            !common.contains { compare($0.0.hashValue, b.hashValue) }
        }.compactMap { b in
            guard let index = second.firstIndex(where: { $0.hashValue == b.hashValue }) else { return nil }
            return DiffItem(index: index, value: b)
        }
        var modified: [DiffItem<T2>] = []
//        print("1 removed: \(removed.map { $0.value.hashValue }), inserted: \(inserted.map { $0.value.hashValue }), modified: \(modified)   a.count: \(first.count)  b.count: \(second.count)")
        inserted.enumerated().forEach { ins in
            guard let _ins = ins.element as? AnyIdentable else { return }
            for rem in removed.enumerated() {
                if let _rem = rem.element as? AnyIdentable {
                    if _rem.identHash() == _ins.identHash() {
                        removed.remove(at: rem.offset)
                        inserted.remove(at: ins.offset)
                        modified.append(ins.element)
                        break
                    }
                }
            }
        }
//        print("2 modified: \(modified)")//removed: \(removed), inserted: \(inserted), modified: \(modified)")
//        print("1 removed: \(removed), inserted: \(inserted), modified: \(modified)   a.count: \(first.count)  b.count: \(second.count)")
//        if inserted.count > 0, first.count - removed.count == second.count {
//            modified = inserted
//            inserted = []
//        }
//        print("2 removed: \(removed), inserted: \(inserted), modified: \(modified)")
        return DiffResult(common: common, removed: removed, inserted: inserted, modified: modified)
    }
}
extension Array where Element: Hashable {
    public func difference<T2: Hashable>(_ new: [T2]) -> DiffResult<Element, T2> {
        difference(self, new, with: ==)
    }
}

public protocol AnyForEach {
    var count: Int { get }
    func allItems() -> [BodyBuilder.Result]
    func items(at index: Int) -> BodyBuilder.Result
    func subscribeToChanges( _ handler: @escaping ([Int], [Int], [Int]) -> Void)
}

public typealias UForEach = ForEach
public class ForEach<Item> where Item: Hashable {
    public typealias BuildViewHandler = (Int, Item) -> BodyBuilder.Result
    public typealias BuildViewHandlerValue = (Item) -> BodyBuilder.Result
    public typealias BuildViewHandlerSimple = () -> BodyBuilder.Result

    let items: BehaviorSubject<[Item]>
    let block: BuildViewHandler

    #if os(macOS)
    public var orientation: NSUserInterfaceLayoutOrientation? { nil }
    #else
    public var axis: NSLayoutConstraint.Axis? { nil }
    #endif

    public init (_ items: [Item], @BodyBuilder block: @escaping BuildViewHandler) {
        self.items = BehaviorSubject(value: items)
        self.block = block
    }

    public init (_ items: [Item], @BodyBuilder block: @escaping BuildViewHandlerValue) {
        self.items = BehaviorSubject(value: items)
        self.block = { _, v in
            block(v)
        }
    }

    public init (_ items: [Item], @BodyBuilder block: @escaping BuildViewHandlerSimple) {
        self.items = BehaviorSubject(value: items)
        self.block = { _,_ in
            block()
        }
    }

    public init (_ items: BehaviorSubject<[Item]>, @BodyBuilder block: @escaping BuildViewHandler) {
        self.items = items
        self.block = block
    }

    public init (_ items: BehaviorSubject<[Item]>, @BodyBuilder block: @escaping BuildViewHandlerValue) {
        self.items = items
        self.block = { _, v in
            block(v)
        }
    }

    public init (_ items: BehaviorSubject<[Item]>, @BodyBuilder block: @escaping BuildViewHandlerSimple) {
        self.items = items
        self.block = { _,_ in
            block()
        }
    }
}

extension ForEach: AnyForEach {
    public var count: Int { try! items.value().count }

    public func allItems() -> [BodyBuilder.Result] {
        try! items.value().enumerated().compactMap { [weak self] in
            self?.block($0.offset, $0.element)
        }
    }

    public func items(at index: Int) -> BodyBuilder.Result {
        guard index < (try! items.value().count) else { return [] }
        return block(index, try! items.value()[index])
    }

    public func subscribeToChanges(_ handler: @escaping ([Int], [Int], [Int]) -> Void) {
        items.__pairwise().subscribe(onNext: { (old, new) in
            let diff = old.difference(new)
            let deletions = diff.removed.compactMap { $0.index }
            let insertions = diff.inserted.compactMap { $0.index }
            let modifications = diff.modified.compactMap { $0.index }
            guard deletions.count > 0 || insertions.count > 0 || modifications.count > 0 else { return }
            handler(deletions, insertions, modifications)
        })
    }
}

extension ForEach: BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem {
        .forEach(self)
    }
}

extension ForEach where Item == Int {
    public convenience init (_ items: ClosedRange<Item>, @BodyBuilder block: @escaping BuildViewHandler) {
        self.init(items.map { $0 }, block: block)
    }

    public convenience init (_ items: ClosedRange<Item>, @BodyBuilder block: @escaping BuildViewHandlerValue) {
        self.init(items.map { $0 }, block: block)
    }

    public convenience init (_ items: ClosedRange<Item>, @BodyBuilder block: @escaping BuildViewHandlerSimple) {
        self.init(items.map { $0 }, block: block)
    }
}
#endif
