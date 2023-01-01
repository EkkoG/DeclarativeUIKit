import EGChainable

extension ChainableObject: BodyBuilderItemable where Base: UIView {
    public var bodyBuilderItem: BodyBuilderItem { .single(self.base) }

    public func asView() -> Base {
        return self.base
    }
}