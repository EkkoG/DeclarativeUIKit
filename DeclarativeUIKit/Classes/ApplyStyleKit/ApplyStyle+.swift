import ApplyStyleKit

extension ApplyStyleProtocol {
    public var A: StyleObject<Self> {
        return applyStyle
    }
}

extension StyleObject {
    public var asView: Base {
        return base
    }
}