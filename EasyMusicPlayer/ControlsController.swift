import Foundation
import MediaPlayer

// sourcery: name = ControlsController
protocol ControlsControlling: AnyObject, Mockable {
    var repeatButtonState: RepeatState? { get }
    var playButtonState: PlayState? { get }

    func setDelegate(_ delegate: ControlsDelegate)
    func setMusicServiceState(_ musicServiceState: MusicServiceState)
    func setRepeatState(_ repeatState: RepeatState)
    func setControlsPlaying()
    func setControlsPaused()
    func setControlsStopped()
}

protocol ControlsDelegate: AnyObject {
    func controlsControllerPressedPlay(_ controller: ControlsControlling)
    func controlsControllerPressedStop(_ controller: ControlsControlling)
    func controlsControllerPressedPrev(_ controller: ControlsControlling)
    func controlsControllerPressedNext(_ controller: ControlsControlling)
    func controlsControllerPressedShuffle(_ controller: ControlsControlling)
    func controlsControllerPressedRepeat(_ controller: ControlsControlling)
}

final class ControlsController: ControlsControlling {
    private let viewController: ControlsViewControlling
    private let remote: RemoteControlling
    private weak var delegate: ControlsDelegate?
    private var musicServiceState: MusicServiceState?

    var repeatButtonState: RepeatState? {
        return viewController.viewState?.repeatButton.state
    }
    var playButtonState: PlayState? {
        return viewController.viewState?.playButton.state
    }
    private var viewState: ControlsViewStating {
        get {
            guard let viewState = viewController.viewState else {
                assertionFailure("expected ControlsViewState")
                return ControlsViewState.default
            }
            return viewState
        }
        set {
            viewController.viewState = newValue
        }
    }

    init(viewController: ControlsViewControlling, remote: RemoteControlling) {
        self.viewController = viewController
        self.remote = remote
        setup()
    }

    func setDelegate(_ delegate: ControlsDelegate) {
        self.delegate = delegate
    }

    func setMusicServiceState(_ musicServiceState: MusicServiceState) {
        self.musicServiceState = musicServiceState
    }

    func setRepeatState(_ repeatState: RepeatState) {
        viewState = viewState.copy(repeatButton: viewState.repeatButton.copy(state: repeatState))
        updateSeekingControls()
    }

    func setControlsPlaying() {
        viewState = viewState.copy(playButton: viewState.playButton.copy(state: .paused))
        remote.pauseCommand.isEnabled = true
        remote.playCommand.isEnabled = false

        setPlayIsEnabled(true)
        setStopIsEnabled(true)
        setShuffleIsEnabled(true)
        setRepeatIsEnabled(true)
        updateSeekingControls()
    }

    func setControlsPaused() {
        viewState = viewState.copy(playButton: viewState.playButton.copy(state: .playing))
        remote.pauseCommand.isEnabled = false
        remote.playCommand.isEnabled = true

        setPlayIsEnabled(true)
        setStopIsEnabled(true)
        setShuffleIsEnabled(true)
        setRepeatIsEnabled(true)
        updateSeekingControls()
    }

    func setControlsStopped() {
        viewState = viewState.copy(playButton: viewState.playButton.copy(state: .playing))
        remote.pauseCommand.isEnabled = false
        remote.playCommand.isEnabled = true

        setPlayIsEnabled(true)
        setStopIsEnabled(false)
        setShuffleIsEnabled(true)
        setRepeatIsEnabled(true)
        updateSeekingControls()
    }

    // MARK: - private

    private func setPreviousIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(prevButton: viewState.prevButton.copy(isEnabled: isEnabled))
        remote.previousTrackCommand.isEnabled = isEnabled
    }

    private func setNextIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(nextButton: viewState.nextButton.copy(isEnabled: isEnabled))
        remote.nextTrackCommand.isEnabled = isEnabled
    }

    private func setSeekBackwardsIsEnabled(_ isEnabled: Bool) {
        remote.seekBackwardCommand.isEnabled = isEnabled
    }

    private func setSeekForwardsIsEnabled(_ isEnabled: Bool) {
        remote.seekForwardCommand.isEnabled = isEnabled
    }

    private func setPlayIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(playButton: viewState.playButton.copy(isEnabled: isEnabled))
        remote.togglePlayPauseCommand.isEnabled = isEnabled
    }

    private func setStopIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(stopButton: viewState.stopButton.copy(isEnabled: isEnabled))
        remote.stopCommand.isEnabled = isEnabled
    }

    private func setShuffleIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(shuffleButton: viewState.shuffleButton.copy(isEnabled: isEnabled))
    }

    private func setRepeatIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(repeatButton: viewState.repeatButton.copy(isEnabled: isEnabled))
    }

    private func updateSeekingControls() {
        guard let musicServiceState = musicServiceState, let repeatButtonState = repeatButtonState else { return }
        switch repeatButtonState {
        case .none, .one:
            let trackNumber = musicServiceState.currentTrackIndex
            let isFirstTrack = trackNumber == 0
            let isLastTrack = trackNumber == (musicServiceState.totalTracks - 1)
            setPreviousIsEnabled(!isFirstTrack && musicServiceState.isPlaying)
            setNextIsEnabled(!isLastTrack && musicServiceState.isPlaying)
        case .all:
            setPreviousIsEnabled(musicServiceState.isPlaying)
            setNextIsEnabled(musicServiceState.isPlaying)
        }
        setSeekBackwardsIsEnabled(musicServiceState.isPlaying)
        setSeekForwardsIsEnabled(musicServiceState.isPlaying)
    }

    // MARK: - private

    private func setup() {
        viewController.setDelegate(self)
        viewState = ControlsViewState.default
        setControlsStopped()
    }
}

// MARK: - ControlsViewDelegate

extension ControlsController: ControlsViewDelegate {
    func controlsViewController(_ viewController: ControlsViewControlling, pressedPlay button: UIButton) {
        button.pulse()
        delegate?.controlsControllerPressedPlay(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedStop button: UIButton) {
        button.pulse()
        delegate?.controlsControllerPressedStop(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedPrev button: UIButton) {
        button.pulse()
        delegate?.controlsControllerPressedPrev(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedNext button: UIButton) {
        button.pulse()
        delegate?.controlsControllerPressedNext(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedShuffle button: UIButton) {
        button.pulse()
        button.spin()
        delegate?.controlsControllerPressedShuffle(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedRepeat button: UIButton) {
        button.pulse()
        setRepeatState(viewState.repeatButton.state.next())
        delegate?.controlsControllerPressedRepeat(self)
    }
}

// MARK: - ControlsViewState

private extension ControlsViewState {
    static var `default` = ControlsViewState(
        playButton: PlayButtonViewState(state: .playing, isEnabled: false),
        stopButton: GenericButtonViewState(isEnabled: false),
        prevButton: GenericButtonViewState(isEnabled: false),
        nextButton: GenericButtonViewState(isEnabled: false),
        shuffleButton: GenericButtonViewState(isEnabled: false),
        repeatButton: RepeatButtonViewState(state: .all, isEnabled: false)
    )
}
