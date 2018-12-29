import UIKit

// sourcery: name = RepeatButton
protocol RepeatButtonable: Mockable {
    var viewState: RepeatButtonViewStating? { get set }
}

@IBDesignable
final class RepeatButton: UIButton, RepeatButtonable {
    var viewState: RepeatButtonViewStating? {
        didSet { _ = viewState.map(bind) }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        _ = viewState.map(bind)
    }

    // MARK: - private

    private func bind(_ viewState: RepeatButtonViewStating) {
        setBackgroundImage(viewState.image, for: .normal)
    }
}

extension RepeatButton {
    override func prepareForInterfaceBuilder() {
        bind(RepeatButtonViewState(state: .all, isEnabled: true))
        super.prepareForInterfaceBuilder()
    }
}
