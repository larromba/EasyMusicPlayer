import UIKit

enum PlayState {
    case play
    case pause
}

struct PlayButtonViewState {
    let state: PlayState
    let isEnabled: Bool
    var image: UIImage {
        switch state {
        case .play:
            return Asset.playButton.image
        case .pause:
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
