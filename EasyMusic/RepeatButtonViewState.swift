import UIKit

struct RepeatButtonViewState {
    let state: RepeatState
    let isEnabled: Bool
    var image: UIImage {
        switch state {
        case .none:
            return Asset.repeatButton.image
        case .one:
            return Asset.repeatOneButton.image
        case .all:
            return Asset.repeatAllButton.image
        }
    }
}

extension RepeatButtonViewState {
    func copy(state: RepeatState) -> RepeatButtonViewState {
        return RepeatButtonViewState(
            state: state,
            isEnabled: isEnabled
        )
    }

    func copy(isEnabled: Bool) -> RepeatButtonViewState {
        return RepeatButtonViewState(
            state: state,
            isEnabled: isEnabled
        )
    }
}
