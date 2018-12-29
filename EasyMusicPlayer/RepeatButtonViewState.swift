import UIKit

protocol RepeatButtonViewStating {
    var state: RepeatState { get }
    var isEnabled: Bool { get }
    var image: UIImage { get }

    func copy(state: RepeatState) -> RepeatButtonViewStating
    func copy(isEnabled: Bool) -> RepeatButtonViewStating
}

struct RepeatButtonViewState: RepeatButtonViewStating {
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
    func copy(state: RepeatState) -> RepeatButtonViewStating {
        return RepeatButtonViewState(
            state: state,
            isEnabled: isEnabled
        )
    }

    func copy(isEnabled: Bool) -> RepeatButtonViewStating {
        return RepeatButtonViewState(
            state: state,
            isEnabled: isEnabled
        )
    }
}
