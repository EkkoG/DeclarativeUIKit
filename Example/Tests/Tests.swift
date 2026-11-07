import XCTest
import UIKit
import Combine
import RxSwift
import EGChainable
@testable import EGDeclarativeUIKit

final class BuilderTests: XCTestCase {
    func testGeneratedInputTraitsAndWritableProtocolProperty() {
        let search = UISearchBar().keyboardType(.emailAddress).autocapitalizationType(.none)
        XCTAssertEqual(search.keyboardType, .emailAddress)
        XCTAssertEqual(search.autocapitalizationType, .none)

        let text = UITextView().text("Hello").returnKeyType(.done).textContentType(.emailAddress)
        XCTAssertEqual(text.returnKeyType, .done)
        XCTAssertEqual(text.textContentType, .emailAddress)
        let start = text.beginningOfDocument
        let end = text.position(from: start, offset: 2)!
        XCTAssertTrue(text.selectedTextRange(text.textRange(from: start, to: end)) === text)
        XCTAssertEqual(text.selectedRange, NSRange(location: 0, length: 2))
    }

    func testDirectModifiersKeepIdentityAndConcreteType() {
        let label = UILabel()
        let configured: UILabel = label.backgroundColor(.red).text("Title").numberOfLines(2)
        XCTAssertTrue(configured === label)
        XCTAssertEqual(label.backgroundColor, .red)
        XCTAssertEqual(label.text, "Title")
        XCTAssertEqual(label.numberOfLines, 2)
        XCTAssertTrue(label.text(nil) === label)
        XCTAssertNil(label.text)

        let button = UIButton()
        XCTAssertTrue(button.title("Save").title("Selected", for: .selected) === button)
        button.setTitle("Native", for: .normal)
        XCTAssertEqual(button.title(for: .normal), "Native")
        XCTAssertEqual(button.title(for: .selected), "Selected")

        let input = UIView()
        let textView = UITextView().inputView(input)
        XCTAssertTrue(textView.inputView === input)
    }

    func testKeyPathConfigurationSupportsCustomAndNestedProperties() {
        final class CustomControl: UIControl { var message = "" }
        let control = CustomControl()
        let configured: CustomControl = control.set(\.message, to: "Ready").set(\.layer.cornerRadius, to: 8)
        XCTAssertTrue(configured === control)
        XCTAssertEqual(control.message, "Ready")
        XCTAssertEqual(control.layer.cornerRadius, 8)
        var message: String?
        control.onValueChanged { message = $0.message }
        control.sendActions(for: .valueChanged)
        XCTAssertEqual(message, "Ready")
    }

    func testBuilderSupportsOptionalBindingAndAvailability() {
        let optional: UILabel? = UILabel("Optional")
        let parent = UIView {
            if let label = optional { label }
            if #available(iOS 16.0, *) { UICalendarView() }
        }
        XCTAssertTrue(parent.subviews.first === optional)
        if #available(iOS 16.0, *) { XCTAssertTrue(parent.subviews.last is UICalendarView) }
    }

    func testBuilderPreservesViewOrderAndIdentity() {
        let views = (0..<8).map { _ in UIView() }
        let optional: UIView? = views[1]
        let missing: UIView? = nil
        let parent = UIView {
            views[0]
            optional
            missing
            if true { views[2] } else { UIView() }
            if false { UIView() }
            for index in 3..<5 { views[index] }
            [views[5], views[6]]
            [views[7]]
        }
        XCTAssertEqual(parent.subviews.map(ObjectIdentifier.init), views.map(ObjectIdentifier.init))
        XCTAssertTrue(UIView {}.subviews.isEmpty)
    }

    func testViewArraysNeedNoConversion() {
        let label = UILabel()
        let view = UIView()
        let items: [UIView] = [label, view.backgroundColor(.red)]
        let stack = UIStackView.V { items }
        XCTAssertEqual(stack.arrangedSubviews, [label, view])
        let otherStack = UIStackView()
        otherStack.addArranged(items)
        XCTAssertEqual(otherStack.arrangedSubviews, [label, view])
        let direct = UIView {
            [UIView().backgroundColor(.blue), UILabel()]
        }
        XCTAssertEqual(direct.subviews.count, 2)
    }

    func testConvenienceInitializersAndStackParameters() {
        let label = UILabel("Title")
        let button = UIButton("Save")
        XCTAssertEqual(label.text, "Title")
        XCTAssertEqual(button.title(for: .normal), "Save")
        XCTAssertEqual(button.buttonType, .system)
        let stack = VStack(spacing: 12, alignment: .leading, distribution: .equalSpacing) {
            label
            button
        }
        XCTAssertEqual(stack.axis, .vertical)
        XCTAssertEqual(stack.spacing, 12)
        XCTAssertEqual(stack.alignment, .leading)
        XCTAssertEqual(stack.distribution, .equalSpacing)
        XCTAssertEqual(HStack { UIView() }.axis, .horizontal)
        XCTAssertEqual(UIStackView.H(spacing: 8) { UIView() }.spacing, 8)
        XCTAssertEqual(UIStackView.V { UIView() }.axis, .vertical)
    }

    func testPendingLayoutsRunInOrderOnceAfterMount() {
        let child = UIView()
        var calls: [Int] = []
        child.onMount { view in
            XCTAssertNotNil(view.superview)
            calls.append(1)
        }
        child.onMount { _ in calls.append(2) }
        XCTAssertTrue(calls.isEmpty)
        let parent = UIView { child }
        XCTAssertTrue(child.superview === parent)
        XCTAssertEqual(calls, [1, 2])
        let otherParent = UIView { child }
        XCTAssertTrue(child.superview === otherParent)
        XCTAssertEqual(calls, [1, 2])
        child.onMount { _ in calls.append(3) }
        XCTAssertEqual(calls, [1, 2, 3])
    }

    func testStackRunsLayoutAfterSettingAxisAndSpacing() {
        let child = UIView()
        var callCount = 0
        child.onMount { view in
            let parent = view.superview as? UIStackView
            XCTAssertEqual(parent?.axis, .vertical)
            XCTAssertEqual(parent?.spacing, 9)
            callCount += 1
        }
        let stack = VStack(spacing: 9) { child.spacingAfterSelf(37.125) }
        XCTAssertEqual(callCount, 1)
        XCTAssertEqual(stack.customSpacing(after: child), 37.125)
    }

    func testLayoutReturnsViewAndAccumulatesSnapKitConstraints() {
        let child = UIView()
        XCTAssertTrue(child.layout { $0.width.equalTo(40) } === child)
        child.layout { $0.height.equalTo(50) }
        let parent = UIView { child }
        XCTAssertTrue(child.superview === parent)
        XCTAssertEqual(Set(child.constraints.map(\.firstAttribute)), [.width, .height])
        child.layout { $0.leading.equalToSuperview().offset(7) }
        XCTAssertTrue(parent.constraints.contains { $0.firstAttribute == .leading })
    }

    func testExecutedLayoutReleasesItsCaptures() {
        final class Token {}
        let child = UIView()
        weak var weakToken: Token?
        autoreleasepool {
            let token = Token()
            weakToken = token
            child.onMount { _ in _ = token }
        }
        XCTAssertNotNil(weakToken)
        let parent = UIView { child }
        XCTAssertNil(weakToken)
        XCTAssertTrue(child.superview === parent)
    }
}

final class BindingTests: XCTestCase {
    func testDirectRxAndStaticModifiersShareTheOriginalView() {
        let source = PublishSubject<String?>()
        let label = UILabel()
        let configured: UILabel = label.text("Initial").text(source).numberOfLines(0)
        XCTAssertTrue(configured === label)
        source.onNext("Bound")
        XCTAssertEqual(label.text, "Bound")
        label.text("Static")
        source.onNext(nil)
        XCTAssertNil(label.text)
        XCTAssertEqual(label.numberOfLines, 0)
    }

    func testDirectCombineOptionalTextAndStaticModifiers() {
        let source = PassthroughSubject<String?, Never>()
        let label = UILabel()
        let configured: UILabel = label.text("Initial").text(source).numberOfLines(0)
        XCTAssertTrue(configured === label)
        source.send("Bound")
        let done = expectation(description: "Optional text is cleared")
        DispatchQueue.main.async {
            XCTAssertEqual(label.text, "Bound")
            source.send(nil)
            DispatchQueue.main.async {
                XCTAssertNil(label.text)
                done.fulfill()
            }
        }
        wait(for: [done], timeout: 2)
    }

    func testRxCompletionKeepsLastValue() {
        let label = UILabel()
        label.text(.just("Hello"))
        XCTAssertEqual(label.text, "Hello")
    }

    func testCombineReceivesLaterValues() {
        let model = Model()
        let label = UILabel().text(model.$text)
        let done = expectation(description: "Value update")
        DispatchQueue.main.async {
            model.text = "World"
            DispatchQueue.main.async {
                XCTAssertEqual(label.text, "World")
                done.fulfill()
            }
        }
        wait(for: [done], timeout: 2)
    }

    func testCombineMappedPublisherAndBackgroundDelivery() {
        let source = PassthroughSubject<String, Never>()
        let label = TrackingLabel()
        let done = expectation(description: "Main thread update")
        label.didChangeText = { value in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(value, "HELLO")
            done.fulfill()
        }
        label.bind(source.map { $0.uppercased() }, to: \.text)
        DispatchQueue.global().async { source.send("hello") }
        wait(for: [done], timeout: 2)
    }

    func testCombineRebindingCancelsOldSource() {
        let old = PassthroughSubject<String, Never>()
        let current = PassthroughSubject<String, Never>()
        let label = UILabel()
        var cancelled = false
        label.text(old.handleEvents(receiveCancel: { cancelled = true }))
        old.send("queued old value")
        label.bind(current, to: \.text)
        XCTAssertTrue(cancelled)
        old.send("stale")
        current.send("current")
        old.send("stale again")
        let done = expectation(description: "Current source wins")
        DispatchQueue.main.async {
            XCTAssertEqual(label.text, "current")
            done.fulfill()
        }
        wait(for: [done], timeout: 2)
    }

    func testCombineBindingsDoNotKeepViewAlive() {
        let source = PassthroughSubject<String, Never>()
        weak var weakLabel: UILabel?
        var cancelled = false
        autoreleasepool {
            let label = UILabel().text(source.handleEvents(receiveCancel: { cancelled = true }))
            weakLabel = label
        }
        XCTAssertNil(weakLabel)
        XCTAssertTrue(cancelled)
    }

    func testCombineOptionalValuesAndCompletion() {
        let image = UIImage()
        let source = PassthroughSubject<UIImage?, Never>()
        let view = UIImageView().image(source)
        source.send(image)
        source.send(nil)
        let done = expectation(description: "Optional values")
        DispatchQueue.main.async {
            XCTAssertNil(view.image)
            source.send(image)
            source.send(completion: .finished)
            DispatchQueue.main.async {
                XCTAssertTrue(view.image === image)
                done.fulfill()
            }
        }
        wait(for: [done], timeout: 2)
    }

    func testCombineButtonStatesAndFieldsHaveIndependentBindings() {
        let normal = PassthroughSubject<String, Never>()
        let selected = PassthroughSubject<String, Never>()
        let replacement = PassthroughSubject<String, Never>()
        let colors = PassthroughSubject<UIColor, Never>()
        let enabled = PassthroughSubject<Bool, Never>()
        let button = UIButton()
            .title(normal)
            .title(selected, for: .selected)
            .titleColor(colors)
            .bind(enabled, to: \.isEnabled)
        button.title(replacement)
        normal.send("stale")
        selected.send("Selected")
        replacement.send("Normal")
        colors.send(.red)
        enabled.send(false)
        let done = expectation(description: "Separate button bindings")
        DispatchQueue.main.async {
            XCTAssertEqual(button.title(for: .normal), "Normal")
            XCTAssertEqual(button.title(for: .selected), "Selected")
            XCTAssertEqual(button.titleColor(for: .normal), .red)
            XCTAssertFalse(button.isEnabled)
            done.fulfill()
        }
        wait(for: [done], timeout: 2)
    }

    func testRxMappedObservableAndBackgroundDelivery() {
        let source = PublishSubject<String>()
        let label = TrackingLabel()
        let done = expectation(description: "Main thread update")
        label.didChangeText = { value in
            XCTAssertTrue(Thread.isMainThread)
            XCTAssertEqual(value, "HELLO")
            done.fulfill()
        }
        label.bind(source.map { $0.uppercased() }, to: \.text)
        DispatchQueue.global().async { source.onNext("hello") }
        wait(for: [done], timeout: 2)
    }

    func testRxRebindingDisposesOldSource() {
        let old = PublishSubject<String>()
        let current = PublishSubject<String>()
        let label = UILabel()
        var disposed = false
        label.text(old.do(onDispose: { disposed = true }))
        label.bind(current.asObservable(), to: \.text)
        XCTAssertTrue(disposed)
        current.onNext("current")
        old.onNext("stale")
        XCTAssertEqual(label.text, "current")
    }

    func testRxBindingsDoNotKeepViewAlive() {
        let source = PublishSubject<String>()
        weak var weakLabel: UILabel?
        var disposed = false
        autoreleasepool {
            let label = UILabel()
            label.text(source.do(onDispose: { disposed = true }))
            weakLabel = label
        }
        XCTAssertNil(weakLabel)
        XCTAssertTrue(disposed)
    }

    func testRxOptionalValuesAndError() {
        let source = PublishSubject<UIImage?>()
        let image = UIImage()
        let view = UIImageView()
        view.image(source)
        source.onNext(image)
        XCTAssertTrue(view.image === image)
        source.onNext(nil)
        XCTAssertNil(view.image)
        source.onNext(image)
        source.onError(TestError.expected)
        XCTAssertTrue(view.image === image)
    }

    func testRxButtonStatesAndFieldsHaveIndependentBindings() {
        let normal = PublishSubject<String>()
        let selected = PublishSubject<String>()
        let replacement = PublishSubject<String>()
        let colors = PublishSubject<UIColor>()
        let button = UIButton()
        button.title(normal).title(selected, for: .selected).titleColor(colors)
        button.title(replacement).bind(Observable.just(false), to: \.isEnabled)
        normal.onNext("stale")
        selected.onNext("Selected")
        replacement.onNext("Normal")
        colors.onNext(.red)
        XCTAssertEqual(button.title(for: .normal), "Normal")
        XCTAssertEqual(button.title(for: .selected), "Selected")
        XCTAssertEqual(button.titleColor(for: .normal), .red)
        XCTAssertFalse(button.isEnabled)
    }

    func testRxReentrantBindingKeepsNewestSubscription() {
        let label = TrackingLabel()
        let current = PublishSubject<String>()
        var disposed = false
        label.didChangeText = { [weak label] value in
            if value == "initial" {
                label?.bind(current.asObservable(), to: \.text)
            }
        }
        let initial = Observable<String>.create { observer in
            observer.onNext("initial")
            return Disposables.create { disposed = true }
        }
        label.bind(initial, to: \.text)
        XCTAssertTrue(disposed)
        current.onNext("current")
        XCTAssertEqual(label.text, "current")
    }

    func testCombineRebindingFromCancellationKeepsNewestSource() {
        let old = PassthroughSubject<String, Never>()
        let middle = PassthroughSubject<String, Never>()
        let newest = PassthroughSubject<String, Never>()
        let label = UILabel()
        label.text(old.handleEvents(receiveCancel: { [weak label] in
            label?.text(newest)
        }))
        label.text(middle)
        newest.send("newest")
        middle.send("stale")
        let done = expectation(description: "Reentrant replacement")
        DispatchQueue.main.async {
            XCTAssertEqual(label.text, "newest")
            done.fulfill()
        }
        wait(for: [done], timeout: 2)
    }

    func testCombineRebindingDuringSubscriptionKeepsNewestSource() {
        let source = PassthroughSubject<String, Never>()
        let newest = PassthroughSubject<String, Never>()
        let label = UILabel()
        label.text(source.handleEvents(receiveSubscription: { [weak label] _ in
            label?.text(newest)
        }))
        newest.send("newest")
        source.send("stale")
        let done = expectation(description: "Reentrant subscription")
        DispatchQueue.main.async {
            XCTAssertEqual(label.text, "newest")
            done.fulfill()
        }
        wait(for: [done], timeout: 2)
    }

    func testRxRebindingFromDisposalKeepsNewestSource() {
        let old = PublishSubject<String>()
        let middle = PublishSubject<String>()
        let newest = PublishSubject<String>()
        let label = UILabel()
        label.text(old.do(onDispose: { [weak label] in
            label?.text(newest)
        }))
        label.text(middle)
        newest.onNext("newest")
        middle.onNext("stale")
        XCTAssertEqual(label.text, "newest")
    }

    func testRxDisposedBindingDoesNotSendItsSynchronousInitialValue() {
        let old = PublishSubject<String>()
        let newest = BehaviorSubject(value: "newest")
        let label = UILabel()
        label.text(old.do(onDispose: { [weak label] in
            label?.text(newest)
        }))
        label.text(.just("stale"))
        XCTAssertEqual(label.text, "newest")
        newest.onNext("next")
        XCTAssertEqual(label.text, "next")
    }

    func testRxSynchronousSequenceStopsUpdatingAfterRebinding() {
        let newest = PublishSubject<String>()
        let label = TrackingLabel()
        var received: [String] = []
        label.didChangeText = { [weak label] value in
            if let value = value { received.append(value) }
            if value == "initial" {
                label?.bind(newest.asObservable(), to: \.text)
            }
        }
        let source = Observable<String>.create { observer in
            observer.onNext("initial")
            observer.onNext("stale")
            return Disposables.create()
        }
        label.bind(source, to: \.text)
        XCTAssertEqual(received, ["initial"])
        newest.onNext("newest")
        XCTAssertEqual(label.text, "newest")
    }
}

final class EventTests: XCTestCase {
    func testTapAndValueChangeUseSeparateEvents() {
        var taps = 0
        let button = UIButton("Save").onTap { taps += 1 }.onTap { taps += 10 }
        button.sendActions(for: .valueChanged)
        XCTAssertEqual(taps, 0)
        button.sendActions(for: .touchUpInside)
        XCTAssertEqual(taps, 11)

        var value = false
        let toggle = UISwitch().onValueChanged { value = $0.isOn }
        toggle.isOn = true
        toggle.sendActions(for: .valueChanged)
        XCTAssertTrue(value)
    }

    func testEventHandlersReleaseWithControl() {
        final class Token {}
        weak var weakControl: UISwitch?
        weak var weakToken: Token?
        autoreleasepool {
            let token = Token()
            let toggle = UISwitch().onValueChanged { _ in _ = token }
            weakControl = toggle
            weakToken = token
        }
        XCTAssertNil(weakControl)
        XCTAssertNil(weakToken)
    }
}

private enum TestError: Error { case expected }

private final class TrackingLabel: UILabel {
    var didChangeText: ((String?) -> Void)?
    override var text: String? {
        didSet { didChangeText?(text) }
    }
}

private final class Model {
    @Published var text = "Hello"
}
