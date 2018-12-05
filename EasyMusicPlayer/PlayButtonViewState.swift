import UIKit

struct PlayButtonViewState {
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
    func copy(state: PlayState) -> PlayButtonViewState {
        return PlayButtonViewState(
            state: state,
            isEnabled: isEnabled
        )
    }

    func copy(isEnabled: Bool) -> PlayButtonViewState {
        return PlayButtonViewState(
            state: state,
            isEnabled: isEnabled
        )
    }
}
