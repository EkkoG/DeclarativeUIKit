import ApplyStyleKit

extension ApplyStyleProtocol {
    public var A: StyleObject<Self> {
        return applyStyle
    }
}

extension StyleObject: BodyBuilderItemable where Base: UIView {
    public var bodyBuilderItem: BodyBuilderItem { .single(self.base) }

    public func asView() -> UIView {
        return self.base
    }
}