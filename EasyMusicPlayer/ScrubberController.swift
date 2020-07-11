import UIKit

// sourcery: name = ScrubberController
protocol ScrubberControlling: AnyObject, Mockable {
    func moveScrubber(percentage: Float)
    func setIsUserInteractionEnabled(_ isEnabled: Bool)
    func setDelegate(_ delegate: ScrubberControllerDelegate)
}

protocol ScrubberControllerDelegate: AnyObject {
    func controller(_ controller: ScrubberControlling, touchMovedToPercentage percentage: Float)
    func controller(_ controller: ScrubberControlling, touchEndedAtPercentage percentage: Float)
}

final class ScrubberController: ScrubberControlling {
    private let viewController: ScrubberViewControlling
    private weak var delegate: ScrubberControllerDelegate?
    private let lowAlpha: CGFloat = 0.65
    private let remote: Remoting

    init(viewController: ScrubberViewControlling, remote: Remoting) {
        self.viewController = viewController
        self.remote = remote
        setup()
    }

    func setDelegate(_ delegate: ScrubberControllerDelegate) {
        self.delegate = delegate
    }

    func moveScrubber(percentage: Float) {
        moveScrubber(x: viewController.viewWidth * CGFloat(percentage))
    }

    func setIsUserInteractionEnabled(_ isEnabled: Bool) {
        viewController.viewState = viewController.viewState?.copy(isUserInteractionEnabled: isEnabled)
        remote.state.isChangePlaybackEnabled = isEnabled
    }

    // MARK: - Private

    private func setup() {
        viewController.setDelegate(self)
        viewController.viewState = ScrubberViewState(
            isUserInteractionEnabled: false,
            barAlpha: lowAlpha,
            barWidth: -1000 // ensure widest screens don't show the scrubber when first appearing
        )
    }

    // swiftlint:disable identifier_name
    private func moveScrubber(x: CGFloat) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(barWidth: x)
    }

    private func animateTouchesEnded() {
        guard let viewState = viewController.viewState else { return }
        UIView.animate(withDuration: 0.15, delay: 0.0, options: .curveEaseIn, animations: { () -> Void in
            self.viewController.viewState = viewState.copy(barAlpha: 1.0)
        })
    }
}

// MARK: - ScrubberViewDelegate

extension ScrubberController: ScrubberViewDelegate {
    func viewController(_ viewController: ScrubberViewControlling, touchesBegan touches: Set<UITouch>,
                        with event: UIEvent?) {
        guard touches.first != nil, let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(barAlpha: lowAlpha)
    }

    func viewController(_ viewController: ScrubberViewControlling, touchesMoved touches: Set<UITouch>,
                        with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let x = viewController.tapLocation(for: touch).x
        moveScrubber(x: x)

        let percentage = Float(x / viewController.viewWidth)
        delegate?.controller(self, touchMovedToPercentage: percentage)
    }

    func viewController(_ viewController: ScrubberViewControlling, touchesEnded touches: Set<UITouch>,
                        with event: UIEvent?) {
        guard let touch = touches.first else { return }

        let percentage = Float(viewController.tapLocation(for: touch).x / viewController.viewWidth)
        delegate?.controller(self, touchEndedAtPercentage: percentage)
        animateTouchesEnded()
    }
}
