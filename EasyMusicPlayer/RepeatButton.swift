import UIKit

protocol RepeatButtonable {
    var viewState: RepeatButtonViewState? { get set }
}

@IBDesignable
final class RepeatButton: UIButton, RepeatButtonable {
    var viewState: RepeatButtonViewState? {
        didSet { _ = viewState.map(bind) }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        _ = viewState.map(bind)
    }

    // MARK: - private

    private func bind(_ viewState: RepeatButtonViewState) {
        setBackgroundImage(viewState.image, for: .normal)
    }
}

extension RepeatButton {
    override func prepareForInterfaceBuilder() {
        bind(RepeatButtonViewState(state: .all, isEnabled: true))
        super.prepareForInterfaceBuilder()
    }
}
