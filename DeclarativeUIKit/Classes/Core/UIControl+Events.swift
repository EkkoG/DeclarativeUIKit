import UIKit

private final class ControlAction: NSObject {
    let action: () -> Void

    init(_ action: @escaping () -> Void) {
        self.action = action
    }

    @objc func invoke() {
        action()
    }
}

private var controlActionsKey: UInt8 = 0

extension UIControl {
    fileprivate func storeAction(for events: UIControl.Event, _ action: @escaping () -> Void) {
        let target = ControlAction(action)
        var targets = objc_getAssociatedObject(self, &controlActionsKey) as? [ControlAction] ?? []
        targets.append(target)
        objc_setAssociatedObject(self, &controlActionsKey, targets, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(target, action: #selector(ControlAction.invoke), for: events)
    }
}

extension UIButton {
    @discardableResult
    public func onTap(_ action: @escaping () -> Void) -> Self {
        storeAction(for: .touchUpInside, action)
        return self
    }
}

extension ViewConfigurable where Self: UIControl {
    @discardableResult
    public func onValueChanged(_ action: @escaping (Self) -> Void) -> Self {
        storeAction(for: .valueChanged) { [weak self] in
            guard let control = self else { return }
            action(control)
        }
        return self
    }
}
