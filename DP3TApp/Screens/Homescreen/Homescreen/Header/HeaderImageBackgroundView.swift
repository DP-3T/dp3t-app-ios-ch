/*
 * Created by Ubique Innovation AG
 * https://www.ubique.ch
 * Copyright (c) 2020. All rights reserved.
 */

import UIKit

class HeaderImageBackgroundView: UIView {
    private let imageView = UIImageView()
    private let colorView = UIView()

    private static let headerImages = [
        UIImage(named: "header-image-basel"),
        UIImage(named: "header-image-bern"),
        UIImage(named: "header-image-chur"),
        UIImage(named: "header-image-geneva"),
        UIImage(named: "header-image-lausanne"),
        UIImage(named: "header-image-locarno"),
        UIImage(named: "header-image-lugano"),
        UIImage(named: "header-image-luzern"),
        UIImage(named: "header-image-st-gallen"),
        UIImage(named: "header-image-zurich"),
    ].compactMap { $0 }

    static var activeImage: UIImage = HeaderImageBackgroundView.headerImages.randomElement()!

    var state: InterfaceStateModel.TracingState {
        didSet { update() }
    }

    public func changeBackgroundRandomly() {
        let chanceToChange = 0.3
        let random = Double.random(in: 0 ..< 1)

        if random < chanceToChange, let image = HeaderImageBackgroundView.headerImages.randomElement() {
            imageView.image = image
            HeaderImageBackgroundView.activeImage = image
        }
    }

    init(initialState: InterfaceStateModel.TracingState) {
        state = initialState

        super.init(frame: .zero)

        setupView()

        update()
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        imageView.image = HeaderImageBackgroundView.activeImage

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        addSubview(colorView)
        colorView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    private func update() {
        let alpha: CGFloat = 0.7

        switch state {
        case .tracingActive:
            colorView.backgroundColor = UIColor.ns_blue.withHighContrastColor(color: UIColor(ub_hexString: "#63a0c7")!).withAlphaComponent(alpha)
        case .tracingDisabled:
            colorView.backgroundColor = UIColor.ns_text.withHighContrastColor(color: UIColor(ub_hexString: "#4a4969")!).withAlphaComponent(alpha)
        case .bluetoothPermissionError, .bluetoothTurnedOff, .timeInconsistencyError, .unexpectedError, .tracingPermissionError:
            colorView.backgroundColor = UIColor.ns_red.withAlphaComponent(alpha)
        case .tracingEnded:
            colorView.backgroundColor = UIColor.ns_purple.withHighContrastColor(color: UIColor(ub_hexString: "#8d6a9f")!).withAlphaComponent(alpha)
        }
    }
}
