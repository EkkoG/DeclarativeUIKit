import UIKit
import EGDeclarativeUIKit
import EGChainable
import RxSwift
import SnapKit

final class ViewController: UIViewController {
    @RxUIPublished private var canSave = true
    @RxUIPublished private var status = "Ready"
    private var titleLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.body {
            VStack(spacing: 16, alignment: .fill) {
                UILabel("Account settings")
                    .font(.preferredFont(forTextStyle: .title1))
                    .adjustsFontForContentSizeCategory(true)
                    .assign(to: &titleLabel)

                UILabel()
                    .text($status)
                    .numberOfLines(0)

                HStack(spacing: 12, alignment: .center) {
                    UILabel("Enable saving")
                    UISwitch()
                        .isOn(canSave)
                        .onValueChanged { [weak self] control in
                            self?.canSave = control.isOn
                        }
                }

                UIButton("Save")
                    .isEnabled($canSave)
                    .onTap { [weak self] in
                        self?.status = "Saved"
                    }
                    .layout { $0.height.equalTo(44) }

                UILabel()
                    .bind($canSave.map { $0 ? "Saving is enabled" : "Saving is disabled" }, to: \.text)

                ["Name", "Email"].map { UILabel($0) }
            }
            .layout { make in
                make.leading.trailing.equalToSuperview().inset(24)
                make.top.equalTo(self.view.safeAreaLayoutGuide).offset(24)
            }
        }
    }
}
