
import UIKit


extension UIView {
    private struct AssociatedKeys {
        static var autolayoutClosure = "autolayoutClosure"
    }

    typealias AutolayoutBuilder = (UIView) -> Void

    var autolayoutBuilder: AutolayoutBuilder? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.autolayoutClosure) as? AutolayoutBuilder
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.autolayoutClosure, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @discardableResult
    public func applyAutoLayout(_ closure: @escaping (UIView) -> Void) -> Self {
        self.autolayoutBuilder = closure
        return self
    }
}

extension UIView {
    public func body(@BodyBuilder closure: () -> BodyBuilderItemable) -> Self{
        add(item: closure())
        return self
    }
    public convenience init(@BodyBuilder closure: () -> BodyBuilderItemable) {
        self.init(frame: .zero)

        add(item: closure())
    }

    private func _addSubview(_ view: UIView) {
        self.addSubview(view)
        if let builder = view.autolayoutBuilder {
            builder(view)
        }
    }


    func add(item: BodyBuilderItemable) {
        switch item.bodyBuilderItem {
        case .single(let view):
            _addSubview(view)
        case .multiple(let views):
            views.forEach { add(item: $0) }
        case .nested(let items):
            items.forEach { add(item: $0) }
        case .none:
            break
        }
    }
}