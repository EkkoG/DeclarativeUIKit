import EGChainable

extension ChainableObject: BodyBuilderItemable where Base: UIView {
    public var bodyBuilderItem: BodyBuilderItem { .single(self.base) }

    public func asView() -> UIView {
        return self.base
    }
}