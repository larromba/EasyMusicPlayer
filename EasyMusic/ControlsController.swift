import Foundation
import MediaPlayer

protocol ControlsControlling: AnyObject {
    var repeatButtonState: RepeatState? { get }
    var playButtonState: PlayState? { get }

    func setDelegate(_ delegate: ControlsDelegate)
    func setMusicPlayerState(_ musicPlayerState: MusicPlayerState)
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
    func controlsControllerPressedShare(_ controller: ControlsControlling)
    func controlsControllerPressedRepeat(_ controller: ControlsControlling)
}

final class ControlsController: ControlsControlling {
    private let viewController: ControlsViewControlling
    private let remote: RemoteControlling
    private weak var delegate: ControlsDelegate?
    private var musicPlayerState: MusicPlayerState?

    var repeatButtonState: RepeatState? {
        return viewController.viewState?.repeatButton.state
    }
    var playButtonState: PlayState? {
        return viewController.viewState?.playButton.state
    }

    init(viewController: ControlsViewControlling, remote: RemoteControlling) {
        self.viewController = viewController
        self.remote = remote
        setup()
    }

    func setDelegate(_ delegate: ControlsDelegate) {
        self.delegate = delegate
    }

    func setMusicPlayerState(_ musicPlayerState: MusicPlayerState) {
        self.musicPlayerState = musicPlayerState
    }

    func setRepeatState(_ repeatState: RepeatState) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(repeatButton: viewState.repeatButton.copy(state: repeatState))
        updateSeekingControls()
    }

    func setControlsPlaying() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .paused))

        setPlayIsEnabled(true)
        setStopIsEnabled(true)
        setShareIsEnabled(true)

        updateSeekingControls()
    }

    func setControlsPaused() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .playing))

        setPlayIsEnabled(true)
        setShuffleIsEnabled(true)
        setStopIsEnabled(true)

        setPreviousIsEnabled(false)
        setNextIsEnabled(false)
        setShareIsEnabled(false)
    }

    func setControlsStopped() {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(state: .playing))

        setPlayIsEnabled(true)
        setShuffleIsEnabled(true)

        setPreviousIsEnabled(false)
        setNextIsEnabled(false)
        setShareIsEnabled(false)
        setStopIsEnabled(false)
    }

    // MARK: - private

    private func setControlsIsEnabled(_ isEnabled: Bool) {
        setPreviousIsEnabled(isEnabled)
        setNextIsEnabled(isEnabled)
        setPlayIsEnabled(isEnabled)
        setStopIsEnabled(isEnabled)
        setShuffleIsEnabled(isEnabled)
        setShareIsEnabled(isEnabled)
        setRepeatIsEnabled(isEnabled)
    }

    private func setPreviousIsEnabled(_ isEnabled: Bool) {
        remote.previousTrackCommand.isEnabled = isEnabled
        remote.seekBackwardCommand.isEnabled = isEnabled

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(prevButton: viewState.prevButton.copy(isEnabled: isEnabled))
    }

    private func setNextIsEnabled(_ isEnabled: Bool) {
        remote.nextTrackCommand.isEnabled = isEnabled
        remote.seekForwardCommand.isEnabled = isEnabled

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(nextButton: viewState.nextButton.copy(isEnabled: isEnabled))
    }

    private func setSeekBackwardsIsEnabled(_ isEnabled: Bool) {
        remote.seekBackwardCommand.isEnabled = isEnabled
    }

    private func setSeekForwardsIsEnabled(_ isEnabled: Bool) {
        remote.seekForwardCommand.isEnabled = isEnabled
    }

    private func setPlayIsEnabled(_ isEnabled: Bool) {
        remote.playCommand.isEnabled = isEnabled

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(playButton: viewState.playButton.copy(isEnabled: isEnabled))
    }

    private func setStopIsEnabled(_ isEnabled: Bool) {
        remote.stopCommand.isEnabled = isEnabled

        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(stopButton: viewState.stopButton.copy(isEnabled: isEnabled))
    }

    private func setShareIsEnabled(_ isEnabled: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(shareButton: viewState.shareButton.copy(isEnabled: isEnabled))
    }

    private func setShuffleIsEnabled(_ isEnabled: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(shuffleButton: viewState.shuffleButton.copy(isEnabled: isEnabled))
    }

    private func setRepeatIsEnabled(_ isEnabled: Bool) {
        guard let viewState = viewController.viewState else { return }
        viewController.viewState = viewState.copy(repeatButton: viewState.repeatButton.copy(isEnabled: isEnabled))

        if let musicPlayerState = musicPlayerState, musicPlayerState.isPlaying {
            updateSeekingControls()
        }
    }

    private func updateSeekingControls() {
        guard let musicPlayerState = musicPlayerState, let repeatButtonState = repeatButtonState else { return }
        switch repeatButtonState {
        case .none:
            let trackNumber = musicPlayerState.currentTrackIndex
            let isFirstTrack = trackNumber == 0
            let isLastTrack = trackNumber == (musicPlayerState.totalTracks - 1)
            setPreviousIsEnabled(!isFirstTrack)
            setSeekBackwardsIsEnabled(isFirstTrack)
            setNextIsEnabled(!isLastTrack)
            setSeekForwardsIsEnabled(isLastTrack)
        case .one:
            setPreviousIsEnabled(true)
            setNextIsEnabled(false)
        case .all:
            setPreviousIsEnabled(true)
            setNextIsEnabled(true)
        }
    }

    // MARK: - private

    private func setup() {
        viewController.setDelegate(self)
        viewController.viewState = ControlsViewState(
            playButton: PlayButtonViewState(state: .playing, isEnabled: false),
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

// MARK: - ControlsViewDelegate

extension ControlsController: ControlsViewDelegate {
    func controlsViewController(_ viewController: ControlsViewControlling, pressedPlay play: UIButton) {
        play.pulse()
        delegate?.controlsControllerPressedPlay(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedStop stop: UIButton) {
        stop.pulse()
        delegate?.controlsControllerPressedStop(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedPrev prev: UIButton) {
        prev.pulse()
        delegate?.controlsControllerPressedPrev(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedNext next: UIButton) {
        next.pulse()
        delegate?.controlsControllerPressedNext(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedShuffle shuffle: UIButton) {
        shuffle.pulse()
        shuffle.spin()
        delegate?.controlsControllerPressedShuffle(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedShare share: UIButton) {
        share.pulse()
        delegate?.controlsControllerPressedShare(self)
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedRepeat repeat: UIButton) {
        guard let viewState = viewController.viewState else { return }
        setRepeatState(viewState.repeatButton.state.next())
        delegate?.controlsControllerPressedRepeat(self)
    }
}
