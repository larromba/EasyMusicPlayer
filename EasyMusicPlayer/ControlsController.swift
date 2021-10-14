import Foundation
import MediaPlayer

// sourcery: name = ControlsController
protocol ControlsControlling: Mockable {
    var repeatButtonState: RepeatState? { get }
    var playButtonState: PlayState? { get }

    func setDelegate(_ delegate: ControlsDelegate)
    func setMusicServiceState(_ musicServiceState: MusicServiceState)
    func setRepeatState(_ repeatState: RepeatState)
    func setControlsPlaying()
    func setControlsPaused()
    func setControlsStopped()
    func setIsAuthorized(_ isAuthorized: Bool)
}

protocol ControlsDelegate: AnyObject {
    func controller(_ controller: ControlsControlling, handleAction action: PlayerAction)
}

final class ControlsController: ControlsControlling {
    private let viewController: ControlsViewControlling
    private let remote: Remoting
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

    init(viewController: ControlsViewControlling, remote: Remoting) {
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
        remote.state.repeatState = repeatState
        updateSeekingControls()
    }

    func setControlsPlaying() {
        viewState = viewState.copy(playButton: viewState.playButton.copy(state: .paused))
        remote.state.isPauseEnabled = true
        remote.state.isPlayEnabled = false

        setPlayIsEnabled(true)
        setStopIsEnabled(true)
        setShuffleIsEnabled(true)
        setRepeatIsEnabled(true)
        updateSeekingControls()
    }

    func setControlsPaused() {
        viewState = viewState.copy(playButton: viewState.playButton.copy(state: .playing))
        remote.state.isPauseEnabled = false
        remote.state.isPlayEnabled = true

        setPlayIsEnabled(true)
        setStopIsEnabled(true)
        setShuffleIsEnabled(true)
        setRepeatIsEnabled(true)
        updateSeekingControls()
    }

    func setControlsStopped() {
        viewState = viewState.copy(playButton: viewState.playButton.copy(state: .playing))
        remote.state.isPauseEnabled = false
        remote.state.isPlayEnabled = true

        setPlayIsEnabled(true)
        setStopIsEnabled(false)
        setShuffleIsEnabled(true)
        setRepeatIsEnabled(true)
        updateSeekingControls()
    }

    func setIsAuthorized(_ isAuthorized: Bool) {
        viewState = viewState.copy(searchButton: viewState.searchButton.copy(isEnabled: isAuthorized))
    }

    // MARK: - private

    private func setup() {
        viewController.setDelegate(self)
        viewState = ControlsViewState.default
        setControlsStopped()
    }

    private func setPreviousIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(prevButton: viewState.prevButton.copy(isEnabled: isEnabled))
        remote.state.isPreviousEnabled = isEnabled
    }

    private func setNextIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(nextButton: viewState.nextButton.copy(isEnabled: isEnabled))
        remote.state.isNextEnabled = isEnabled
    }

    private func setSeekBackwardsIsEnabled(_ isEnabled: Bool) {
        remote.state.isSeekBackwardEnabled = isEnabled
    }

    private func setSeekForwardsIsEnabled(_ isEnabled: Bool) {
        remote.state.isSeekForwardEnabled = isEnabled
    }

    private func setPlayIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(playButton: viewState.playButton.copy(isEnabled: isEnabled))
    }

    private func setStopIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(stopButton: viewState.stopButton.copy(isEnabled: isEnabled))
        remote.state.isStopEnabled = isEnabled
    }

    private func setShuffleIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(shuffleButton: viewState.shuffleButton.copy(isEnabled: isEnabled))
    }

    private func setRepeatIsEnabled(_ isEnabled: Bool) {
        viewState = viewState.copy(repeatButton: viewState.repeatButton.copy(isEnabled: isEnabled))
        remote.state.isRepeatModeEnabled = isEnabled
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
}

// MARK: - ControlsViewDelegate

extension ControlsController: ControlsViewDelegate {
    func viewController(_ viewController: ControlsViewControlling, handleAction action: PlayerAction,
                        forButton button: UIButton) {
        button.pulse()
        if action == .changeRepeatMode {
            setRepeatState(viewState.repeatButton.state.next())
        }
        if action == .shuffle {
            button.spin()
        }
        delegate?.controller(self, handleAction: action)
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
        repeatButton: RepeatButtonViewState(state: .all, isEnabled: false),
        searchButton: GenericButtonViewState(isEnabled: false)
    )
}
