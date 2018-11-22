import Foundation
import MediaPlayer

protocol ControlsControlling: AnyObject {
    var repeatButtonState: RepeatState? { get set }
    var playButtonState: PlayState? { get }

    func setControlsPlaying()
    func setControlsPaused()
    func setControlsStopped()
    func setControlsIsEnabled(_ isEnabled: Bool)
    func setPreviousIsEnabled(_ isEnabled: Bool)
    func setNextIsEnabled(_ isEnabled: Bool)
    func setSeekBackwardsIsEnabled(_ isEnabled: Bool)
    func setSeekForwardsIsEnabled(_ isEnabled: Bool)
    func setPlayIsEnabled(_ isEnabled: Bool)
    func setStopIsEnabled(_ isEnabled: Bool)
    func setShareIsEnabled(_ isEnabled: Bool)
    func setShuffleIsEnabled(_ isEnabled: Bool)
    func setRepeatIsEnabled(_ isEnabled: Bool)
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
    var playButtonState: PlayState? {
        return viewController.viewState?.playButton.state
    }

    init(viewController: ControlsViewControlling, remote: RemoteControlling) {
        self.viewController = viewController
        self.remote = remote
        setup()
    }

    func setControlsPlaying() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .pause))
        setControlsIsEnabled(true)
    }

    func setControlsPaused() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .play))

        setPlayIsEnabled(true)
        setShuffleIsEnabled(true)
        setStopIsEnabled(true)

        setPreviousIsEnabled(false)
        setNextIsEnabled(false)
        setShareIsEnabled(false)
    }

    func setControlsStopped() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .play))

        setPlayIsEnabled(true)
        setShuffleIsEnabled(true)

        setPreviousIsEnabled(false)
        setNextIsEnabled(false)
        setShareIsEnabled(false)
        setStopIsEnabled(false)
    }

    func setControlsIsEnabled(_ isEnabled: Bool) {
        setPreviousIsEnabled(isEnabled)
        setNextIsEnabled(isEnabled)
        setPlayIsEnabled(isEnabled)
        setStopIsEnabled(isEnabled)
        setShuffleIsEnabled(isEnabled)
        setShareIsEnabled(isEnabled)
        setRepeatIsEnabled(isEnabled)
    }

    func setPreviousIsEnabled(_ isEnabled: Bool) {
        remote.previousTrackCommand.isEnabled = isEnabled
        remote.seekBackwardCommand.isEnabled = isEnabled

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(prevButton: viewState.prevButton.copy(isEnabled: isEnabled))
    }

    func setNextIsEnabled(_ isEnabled: Bool) {
        remote.nextTrackCommand.isEnabled = isEnabled
        remote.seekForwardCommand.isEnabled = isEnabled

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(nextButton: viewState.nextButton.copy(isEnabled: isEnabled))
    }

    func setSeekBackwardsIsEnabled(_ isEnabled: Bool) {
        remote.previousTrackCommand.isEnabled = isEnabled // TODO: should it be here?
        remote.seekBackwardCommand.isEnabled = isEnabled
    }

    func setSeekForwardsIsEnabled(_ isEnabled: Bool) {
        remote.nextTrackCommand.isEnabled = isEnabled // TODO: should it be here?
        remote.seekForwardCommand.isEnabled = isEnabled
    }

    func setPlayIsEnabled(_ isEnabled: Bool) {
        remote.playCommand.isEnabled = isEnabled

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(isEnabled: isEnabled))
    }

    func setStopIsEnabled(_ isEnabled: Bool) {
        remote.stopCommand.isEnabled = isEnabled

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(stopButton: viewState.stopButton.copy(isEnabled: isEnabled))
    }

    func setShareIsEnabled(_ isEnabled: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(shareButton: viewState.shareButton.copy(isEnabled: isEnabled))
    }

    func setShuffleIsEnabled(_ isEnabled: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(shuffleButton: viewState.shuffleButton.copy(isEnabled: isEnabled))
    }

    func setRepeatIsEnabled(_ isEnabled: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(repeatButton: viewState.repeatButton.copy(isEnabled: isEnabled))
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
