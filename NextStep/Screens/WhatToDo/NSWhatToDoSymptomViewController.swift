///

import UIKit

class NSWhatToDoSymptomViewController: NSViewController {
    // MARK: - Views

    private let stackScrollView = NSStackScrollView(axis: .vertical, spacing: 0)
    private let symptomView = NSWhatToDoSymptomView()

    private let titleElement = UIAccessibilityElement(accessibilityContainer: self)
    private var titleContentStackView = UIStackView()
    private var subtitleLabel: NSLabel!
    private var titleLabel: NSLabel!

    // MARK: - Init

    override init() {
        super.init()
        title = "symptom_detail_navigation_title".ub_localized
    }

    // MARK: - View

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.ns_backgroundSecondary

        setupStackScrollView()
        setupLayout()

        setupAccessibility()
    }

    // MARK: - Setup

    private func setupStackScrollView() {
        stackScrollView.stackView.isLayoutMarginsRelativeArrangement = true
        stackScrollView.stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)

        view.addSubview(stackScrollView)
        stackScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func setupLayout() {
        titleContentStackView.axis = .vertical
        stackScrollView.addSpacerView(NSPadding.large)

        // Title & subtitle
        subtitleLabel = NSLabel(.textLight, textAlignment: .center)
        subtitleLabel.text = "symptom_detail_subtitle".ub_localized

        titleLabel = NSLabel(.title, textAlignment: .center)
        titleLabel.text = "symptom_detail_title".ub_localized

        titleContentStackView.addArrangedView(subtitleLabel)
        titleContentStackView.addArrangedView(titleLabel)
        titleContentStackView.addSpacerView(3.0)

        stackScrollView.addArrangedView(titleContentStackView)

        stackScrollView.addSpacerView(NSPadding.large)

        let imageView = UIImageView(image: UIImage(named: "illu-symptome-title"))
        imageView.contentMode = .scaleAspectFit
        stackScrollView.addArrangedView(imageView)

        stackScrollView.addSpacerView(NSPadding.large)

        stackScrollView.addArrangedView(symptomView)

        stackScrollView.addSpacerView(3.0 * NSPadding.large)

        let infoView = NSOnboardingInfoView(icon: UIImage(named: "ic-check-round")!, text: "symptom_faq1_text".ub_localized, title: "symptom_faq1_title".ub_localized, leftRightInset: 0)

        stackScrollView.addArrangedView(infoView)

        let buttonView = UIView()

        let externalLinkButton = NSExternalLinkButton(color: .ns_purple)
        externalLinkButton.title = "symptom_detail_box_button".ub_localized
        externalLinkButton.touchUpCallback = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.presentCoronaCheck()
        }

        buttonView.addSubview(externalLinkButton)
        externalLinkButton.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview()
            make.right.lessThanOrEqualToSuperview()
        }

        infoView.stackView.addSpacerView(2 * NSPadding.medium)
        infoView.stackView.addArrangedView(buttonView)

        stackScrollView.addSpacerView(3 * NSPadding.large)

        stackScrollView.addArrangedView(NSButton.faqButton(color: .ns_purple))

        stackScrollView.addSpacerView(NSPadding.large)
    }

    private func setupAccessibility() {
        titleContentStackView.isAccessibilityElement = true
        titleContentStackView.accessibilityLabel = subtitleLabel.text!.deleteSuffix("...") + titleLabel.text!
        accessibilityElements = [titleContentStackView, symptomView]
    }

    // MARK: - Detail

    private func presentCoronaCheck() {
        if let url =
            URL(string: "symptom_detail_corona_check_url".ub_localized) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension String {
    func deleteSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }
}
