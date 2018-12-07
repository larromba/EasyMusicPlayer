import UIKit

struct GenericButtonViewState {
    var isEnabled: Bool
}

extension GenericButtonViewState {
    func copy(isEnabled: Bool) -> GenericButtonViewState {
        return GenericButtonViewState(
            isEnabled: isEnabled
        )
    }
}

// MARK: - UIButton

extension UIButton {
    func bind(_ state: GenericButtonViewState) {
        isEnabled = state.isEnabled
    }
}
