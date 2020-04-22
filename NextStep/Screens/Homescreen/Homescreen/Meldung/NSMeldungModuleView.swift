/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class NSMeldungView: NSModuleBaseView {
    var uiState: NSUIStateModel.Homescreen.Meldungen
        = .init(meldung: .noMeldung, pushProblem: false) {
        didSet { updateLayout() }
    }

    // section views
    private let noMeldungenView = NSInfoBoxView(title: "meldungen_no_meldungen_title".ub_localized, subText: "meldungen_no_meldungen_subtitle".ub_localized, image: UIImage(named: "ic-check")!, illustration: UIImage(named: "illu-no-message")!, titleColor: .ns_green, subtextColor: .ns_text, backgroundColor: .ns_greenBackground)

    private let exposedView = NSInfoBoxView(title: "meldungen_meldung_title".ub_localized, subText: "meldungen_meldung_text".ub_localized, image: UIImage(named: "ic-info")!, titleColor: .white, subtextColor: .white, backgroundColor: .ns_blue, hasBubble: true)

    private let infectedView = NSInfoBoxView(title: "meldung_homescreen_positiv_title".ub_localized, subText: "meldung_homescreen_positiv_text".ub_localized, image: UIImage(named: "ic-info")!, titleColor: .white, subtextColor: .white, backgroundColor: .ns_purple)

    private let noPushView = NSTracingErrorView(model: NSTracingErrorView.NSTracingErrorViewModel(icon: UIImage(named: "ic-push-disabled")!, title: "push_deactivated_title".ub_localized, text: "push_deactivated_text".ub_localized, buttonTitle: "push_open_settings_button".ub_localized, action: {
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(settingsUrl) else { return }

        UIApplication.shared.open(settingsUrl)
    }))

    override init() {
        super.init()

        headerTitle = "reports_title_homescreen".ub_localized

        updateLayout()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func sectionViews() -> [UIView] {
        var views = [UIView]()

        switch uiState.meldung {
        case .noMeldung:
            views.append(noMeldungenView)
            if uiState.pushProblem {
                views.append(noPushView)
            }
        case .exposed:
            views.append(exposedView)
            views.append(NSMoreInfoView(line1: "exposed_info_contact_hotline".ub_localized, line2: "exposed_info_tel_button_title".ub_localized))
        case .infected:
            views.append(infectedView)
            views.append(NSMoreInfoView(line1: "meldung_homescreen_positive_info_line1".ub_localized, line2: "meldung_homescreen_positive_info_line2".ub_localized))
        }

        return views
    }

    override func updateLayout() {
        super.updateLayout()

        setCustomSpacing(NSPadding.medium, after: noMeldungenView)
        setCustomSpacing(NSPadding.medium, after: exposedView)
        setCustomSpacing(NSPadding.medium, after: infectedView)
    }
}

private class NSMoreInfoView: UIView {
    private let line1Label = NSLabel(.text)
    private let line2Label = NSLabel(.textBold)
    init(line1: String, line2: String) {
        super.init(frame: .zero)

        setupView()

        line1Label.text = line1
        line2Label.text = line2
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        let container = UIView()
        addSubview(container)
        container.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(NSPadding.small)
            make.centerX.equalToSuperview()
        }

        container.addSubview(line1Label)
        container.addSubview(line2Label)

        line1Label.snp.makeConstraints { make in
            make.top.leading.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
        line2Label.snp.makeConstraints { make in
            make.top.equalTo(line1Label.snp.bottom).offset(NSPadding.small)
            make.leading.bottom.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
        }
    }
}
