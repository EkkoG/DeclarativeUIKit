
import UIKit


extension UIView {
    private struct AssociatedKeys {
        static var autolayoutClosures: UInt8 = 0
    }

    typealias AutolayoutBuilder = (UIView) -> Void

    private var autolayoutBuilders: [AutolayoutBuilder] {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.autolayoutClosures) as? [AutolayoutBuilder] ?? []
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.autolayoutClosures, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    @discardableResult
    public func applyAutoLayout(_ closure: @escaping (UIView) -> Void) -> Self {
        autolayoutBuilders.append(closure)
        if superview != nil {
            applyPendingAutoLayout()
        }
        return self
    }

    func applyPendingAutoLayout() {
        let builders = autolayoutBuilders
        // Release pending work before callbacks can register more layout work.
        autolayoutBuilders = []
        builders.forEach { $0(self) }
    }
}

extension UIView {
    @discardableResult
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
        view.applyPendingAutoLayout()
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
