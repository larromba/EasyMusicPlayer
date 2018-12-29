import UIKit

protocol PlayButtonViewStating {
    var state: PlayState { get }
    var isEnabled: Bool { get }
    var image: UIImage { get }

    func copy(state: PlayState) -> PlayButtonViewStating
    func copy(isEnabled: Bool) -> PlayButtonViewStating
}

struct PlayButtonViewState: PlayButtonViewStating {
    let state: PlayState
    let isEnabled: Bool
    var image: UIImage {
        switch state {
        case .playing:
            return Asset.playButton.image
        case .paused, .finished, .stopped:
            return Asset.pauseButton.image
        }
    }
}

extension PlayButtonViewState {
    func copy(state: PlayState) -> PlayButtonViewStating {
        return PlayButtonViewState(
            state: state,
            isEnabled: isEnabled
        )
    }

    func copy(isEnabled: Bool) -> PlayButtonViewStating {
        return PlayButtonViewState(
            state: state,
            isEnabled: isEnabled
        )
    }
}
