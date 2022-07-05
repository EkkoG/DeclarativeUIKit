//
// Created by Kevin Guo on 2022/7/3.
//

import UIKit

public enum BodyBuilderItem {
    case none
    case single(UIView)
    case multiple([UIView])
    case nested([BodyBuilderItemable])
}
public protocol BodyBuilderItemable {
    var bodyBuilderItem: BodyBuilderItem { get }
}
public struct EmptyBodyBuilderItem: BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem { .none }
}
extension UIView: BodyBuilderItemable {
    public var bodyBuilderItem: BodyBuilderItem { .single(self) }
}
extension Array: BodyBuilderItemable where Element: UIView {
    public var bodyBuilderItem: BodyBuilderItem { .multiple(self) }
}
extension Optional: BodyBuilderItemable where Wrapped: UIView {
    public var bodyBuilderItem: BodyBuilderItem {
        switch self {
        case .none: return .none
        case .some(let value): return .single(value)
        }
    }
}

public struct BodyBuilderItems: BodyBuilderItemable {
    var items: [BodyBuilderItemable] = []

    public var bodyBuilderItem: BodyBuilderItem {
        .nested(items)
    }
}

@resultBuilder public struct BodyBuilder {
    public typealias Result = BodyBuilderItemable
    public typealias SingleView = () -> Result

    /// Builds an empty view from an block containing no statements, `{ }`.
    public static func buildBlock() -> Result { [] }

    /// Passes a single view written as a child view (e..g, `{ Text("Hello") }`) through unmodified.
    public static func buildBlock(_ attrs: BodyBuilderItemable...) -> Result {
        buildBlock(attrs)
    }

    /// Passes a single view written as a child view (e..g, `{ Text("Hello") }`) through unmodified.
    public static func buildBlock(_ attrs: [BodyBuilderItemable]) -> Result {
        BodyBuilderItems(items: attrs)
    }

    /// Provides support for "if" statements in multi-statement closures, producing an `Optional` view
    /// that is visible only when the `if` condition evaluates `true`.
    public static func buildIf(_ content: BodyBuilderItemable?) -> Result {
        guard let content = content else { return EmptyBodyBuilderItem() }
        return content
    }

    /// Provides support for "if" statements in multi-statement closures, producing
    /// ConditionalContent for the "then" branch.
    public static func buildEither(first: BodyBuilderItemable) -> Result {
        first
    }

    /// Provides support for "if-else" statements in multi-statement closures, producing
    /// ConditionalContent for the "else" branch.
    public static func buildEither(second: BodyBuilderItemable) -> Result {
        second
    }
}
