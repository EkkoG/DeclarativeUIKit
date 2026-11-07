
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
    func onMount(_ closure: @escaping (UIView) -> Void) -> Self {
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
    public func body(@BodyBuilder closure: () -> [UIView]) -> Self {
        add(closure())
        return self
    }

    public convenience init(@BodyBuilder closure: () -> [UIView]) {
        self.init(frame: .zero)

        add(closure())
    }

    private func _addSubview(_ view: UIView) {
        self.addSubview(view)
        view.applyPendingAutoLayout()
    }


    func add(_ views: [UIView]) {
        views.forEach { _addSubview($0) }
    }
}
