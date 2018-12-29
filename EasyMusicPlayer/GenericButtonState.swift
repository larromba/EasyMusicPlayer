import UIKit

protocol GenericButtonViewStating {
    var isEnabled: Bool { get }

    func copy(isEnabled: Bool) -> GenericButtonViewStating
}

struct GenericButtonViewState: GenericButtonViewStating {
    var isEnabled: Bool
}

extension GenericButtonViewState {
    func copy(isEnabled: Bool) -> GenericButtonViewStating {
        return GenericButtonViewState(
            isEnabled: isEnabled
        )
    }
}

// MARK: - UIButton

extension UIButton {
    func bind(_ state: GenericButtonViewStating) {
        isEnabled = state.isEnabled
    }
}
