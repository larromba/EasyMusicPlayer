import UIKit

// sourcery: name = PlayButton
protocol PlayButtonable: Mockable {
    var viewState: PlayButtonViewStating? { get set }
}

@IBDesignable
final class PlayButton: UIButton, PlayButtonable {
    var viewState: PlayButtonViewStating? {
        didSet { _ = viewState.map(bind) }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        _ = viewState.map(bind)
    }

    // MARK: - private

    private func bind(_ viewState: PlayButtonViewStating) {
        setBackgroundImage(viewState.image, for: .normal)
    }
}

extension PlayButton {
    override func prepareForInterfaceBuilder() {
        bind(PlayButtonViewState(state: .playing, isEnabled: true))
        super.prepareForInterfaceBuilder()
    }
}
