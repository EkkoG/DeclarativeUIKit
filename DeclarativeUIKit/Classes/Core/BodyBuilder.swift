import UIKit

@resultBuilder
public struct BodyBuilder {
    public static func buildExpression(_ view: UIView) -> [UIView] { [view] }
    public static func buildExpression(_ view: UIView?) -> [UIView] { view.map { [$0] } ?? [] }
    public static func buildExpression(_ views: [UIView]) -> [UIView] { views }

    public static func buildBlock(_ components: [UIView]...) -> [UIView] {
        components.flatMap { $0 }
    }

    public static func buildOptional(_ component: [UIView]?) -> [UIView] { component ?? [] }
    public static func buildEither(first component: [UIView]) -> [UIView] { component }
    public static func buildEither(second component: [UIView]) -> [UIView] { component }
    public static func buildArray(_ components: [[UIView]]) -> [UIView] { components.flatMap { $0 } }
    public static func buildLimitedAvailability(_ component: [UIView]) -> [UIView] { component }
}
