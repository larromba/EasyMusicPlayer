import Foundation
import MediaPlayer

protocol ControlsControlling: AnyObject {
    var repeatButtonState: RepeatState? { get set }
    var viewState: ControlsViewState? { get }

    func setControlsPlaying()
    func setControlsPaused()
    func setControlsStopped()
    func setControlsEnabled(_ enabled: Bool)
    func enablePrevious(_ enable: Bool)
    func enableNext(_ enable: Bool)
    func enableSeekBackwardsRemoteOnly(_ enable: Bool)
    func enableSeekForwardsRemoteOnly(_ enable: Bool)
    func enablePlay(_ enable: Bool)
    func enableStop(_ enable: Bool)
    func enableShare(_ enable: Bool)
    func enableShuffle(_ enable: Bool)
    func enableRepeat(_ enable: Bool)
}

final class ControlsController: ControlsControlling {
    private let viewController: ControlsViewControlling
    private let remote: RemoteControlling

    var viewState: ControlsViewState? {
        return viewController.viewState
    }
    var repeatButtonState: RepeatState? {
        set {
            guard let newValue = newValue, let viewState = viewController.viewState else { return }
            viewController.viewState = viewState.copy(repeatButton: viewState.repeatButton.copy(state: newValue))
        }
        get {
            return viewController.viewState?.repeatButton.state
        }
    }

    init(viewController: ControlsViewControlling, remote: RemoteControlling) {
        self.viewController = viewController
        self.remote = remote
        setup()
    }

    func setControlsPlaying() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .pause))
        setControlsEnabled(true)
    }

    func setControlsPaused() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .play))

        enablePlay(true)
        enableShuffle(true)
        enableStop(true)

        enablePrevious(false)
        enableNext(false)
        enableShare(false)
    }

    func setControlsStopped() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .play))

        enablePlay(true)
        enableShuffle(true)

        enablePrevious(false)
        enableNext(false)
        enableShare(false)
        enableStop(false)
    }

    func setControlsEnabled(_ enabled: Bool) {
        enablePrevious(enabled)
        enableNext(enabled)
        enablePlay(enabled)
        enableStop(enabled)
        enableShuffle(enabled)
        enableShare(enabled)
        enableRepeat(enabled)
    }

    func enablePrevious(_ enable: Bool) {
        remote.previousTrackCommand.isEnabled = enable
        remote.seekBackwardCommand.isEnabled = enable

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(prevButton: viewState.prevButton.copy(isEnabled: enable))
    }

    func enableNext(_ enable: Bool) {
        remote.nextTrackCommand.isEnabled = enable
        remote.seekForwardCommand.isEnabled = enable

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(nextButton: viewState.nextButton.copy(isEnabled: enable))
    }

    func enableSeekBackwardsRemoteOnly(_ enable: Bool) {
        remote.previousTrackCommand.isEnabled = enable
        remote.seekBackwardCommand.isEnabled = enable
    }

    func enableSeekForwardsRemoteOnly(_ enable: Bool) {
        remote.nextTrackCommand.isEnabled = enable
        remote.seekForwardCommand.isEnabled = enable
    }

    func enablePlay(_ enable: Bool) {
        remote.playCommand.isEnabled = enable

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(isEnabled: enable))
    }

    func enableStop(_ enable: Bool) {
        remote.stopCommand.isEnabled = enable

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(stopButton: viewState.stopButton.copy(isEnabled: enable))
    }

    func enableShare(_ enable: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(shareButton: viewState.shareButton.copy(isEnabled: enable))
    }

    func enableShuffle(_ enable: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(shuffleButton: viewState.shuffleButton.copy(isEnabled: enable))
    }

    func enableRepeat(_ enable: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(repeatButton: viewState.repeatButton.copy(isEnabled: enable))
    }

    // MARK: - private

    private func setup() {
        viewController.viewState = ControlsViewState(
            playButton: PlayButtonViewState(state: .play, isEnabled: false),
            stopButton: GenericButtonViewState(isEnabled: false),
            prevButton: GenericButtonViewState(isEnabled: false),
            nextButton: GenericButtonViewState(isEnabled: false),
            shuffleButton: GenericButtonViewState(isEnabled: false),
            shareButton: GenericButtonViewState(isEnabled: false),
            repeatButton: RepeatButtonViewState(state: .all, isEnabled: false)
        )
        setControlsStopped()
    }
}
