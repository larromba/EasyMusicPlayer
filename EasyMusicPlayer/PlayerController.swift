import UIKit

// sourcery: name = PlayerController
protocol PlayerControlling: Mockable {
    func setDelegate(_ delegate: PlayerControllerDelegate)
    func play(_ track: Track)
}

protocol PlayerControllerDelegate: AnyObject {
    func controller(_ controller: PlayerControlling, showAlert alert: Alert)
    func controller(_ controller: PlayerControlling, prepareForSegue segue: UIStoryboardSegue, sender: Any?)
}

final class PlayerController: PlayerControlling {
    private let viewController: PlayerViewControlling
    private let scrubberController: ScrubberControlling
    private let infoController: InfoControlling
    private let controlsController: ControlsControlling
    private let musicService: MusicServicing
    private let userService: UserServicing
    private var isUserScrubbing = false
    private let authorization: Authorization
    private var lastKnownPlayState: PlayState = .stopped
    private weak var delegate: PlayerControllerDelegate?

    init(viewController: PlayerViewControlling,
         scrubberController: ScrubberControlling,
         infoController: InfoControlling,
         controlsController: ControlsControlling,
         musicService: MusicServicing,
         userService: UserServicing,
         authorization: Authorization) {
        self.viewController = viewController
        self.scrubberController = scrubberController
        self.infoController = infoController
        self.controlsController = controlsController
        self.musicService = musicService
        self.userService = userService
        self.authorization = authorization
        setup()
    }

    func setDelegate(_ delegate: PlayerControllerDelegate) {
        self.delegate = delegate
    }

    func play(_ track: Track) {
        musicService.stop()
        guard musicService.prime(track) else {
            delegate?.controller(self, showAlert: .playError)
            return
        }
        musicService.play()
    }

    // MARK: - private

    private func setup() {
        viewController.setDelegate(self)
        scrubberController.setDelegate(self)
        controlsController.setDelegate(self)
        musicService.setDelegate(self)

        if let repeatMode = userService.repeatState {
            musicService.setRepeatState(repeatMode)
            controlsController.setRepeatState(repeatMode)
        }
        #if DEBUG // override repeatMode if snapshotting
        if __isSnapshot {
            musicService.setRepeatState(.all)
            controlsController.setRepeatState(.all)
        }
        #endif

        viewController.viewState = PlayerViewState(appVersion: Bundle.appVersion)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    // MARK: - notification

    @objc
    private func applicationDidBecomeActive() {
        controlsController.setIsAuthorized(authorization.isAuthorized)

        // this keeps the ui in sync with any state changes whilst inactive
        guard lastKnownPlayState != musicService.state.playState else { return }
        musicService(musicService, changedState: musicService.state.playState)
    }
}

// MARK: - MusicServiceDelegate

extension PlayerController: MusicServiceDelegate {
    func musicService(_ sender: MusicServicing, changedState state: PlayState) {
        lastKnownPlayState = state
        controlsController.setMusicServiceState(sender.state)
        switch state {
        case .playing:
            controlsController.setControlsPlaying()
            infoController.setInfoFromTrack(sender.state.currentTrack)
            infoController.setTrackPosition((sender.state.currentTrackIndex + 1),
                                            totalTracks: sender.state.totalTracks)
            scrubberController.setIsUserInteractionEnabled(true)
        case .paused:
            controlsController.setControlsPaused()
            scrubberController.setIsUserInteractionEnabled(false)
        case .stopped:
            controlsController.setControlsStopped()
            infoController.clearInfo()
            scrubberController.setIsUserInteractionEnabled(false)
            scrubberController.moveScrubber(percentage: 0)
        case .finished:
            controlsController.setControlsStopped()
            infoController.clearInfo()
            scrubberController.setIsUserInteractionEnabled(false)
            scrubberController.moveScrubber(percentage: 0)
            delegate?.controller(self, showAlert: .finished)
        }
    }

    func musicService(_ service: MusicServicing, changedRepeatState state: RepeatState) {
        userService.repeatState = state
        controlsController.setRepeatState(state)
    }

    func musicService(_ sender: MusicServicing, changedPlaybackTime playbackTime: TimeInterval) {
        guard !isUserScrubbing else { return }

        let duration = musicService.state.currentTrack.duration
        let percentage = duration > 0 ? playbackTime / duration : 0

        scrubberController.moveScrubber(percentage: Float(percentage))
        infoController.setTime(playbackTime, duration: duration)
    }

    func musicService(_ service: MusicServicing, threwError error: MusicError) {
        switch error {
        case .noMusic:
            infoController.clearInfo()
            delegate?.controller(self, showAlert: .noMusic)
        case .noVolume:
            delegate?.controller(self, showAlert: .noVolume)
        case .avError:
            delegate?.controller(self, showAlert: .trackError(title: service.state.currentTrack.title))
        case .decode, .playerInit:
            service.skip()
        case .authorization:
            delegate?.controller(self, showAlert: .authError)
        }
    }
}

// MARK: - ScrubberControllerDelegates

extension PlayerController: ScrubberControllerDelegate {
    func controller(_ controller: ScrubberControlling, touchMovedToPercentage percentage: Float) {
        isUserScrubbing = true
        let duration = musicService.state.currentTrack.duration
        let time = duration * TimeInterval(percentage)
        infoController.setTime(time, duration: duration)
    }

    func controller(_ controller: ScrubberControlling, touchEndedAtPercentage percentage: Float) {
        let duration = musicService.state.currentTrack.duration
        let time = duration * TimeInterval(percentage)
        infoController.setTime(time, duration: duration)
        musicService.setTime(time)
        isUserScrubbing = false
    }
}

// MARK: - ControlsDelegate

extension PlayerController: ControlsDelegate {
    func controller(_ controller: ControlsControlling, handleAction action: PlayerAction) {
        switch action {
        case .play:
            if musicService.state.isPlaying {
                musicService.pause()
            } else {
                musicService.play()
            }
        case .stop:
            musicService.stop()
        case .prev:
            musicService.previous()
        case .next:
            musicService.next()
        case .shuffle:
            musicService.stop()
            musicService.shuffle()
            musicService.play()
        case .changeRepeatMode:
            guard let repeatState = controller.repeatButtonState else { return }
            musicService.setRepeatState(repeatState)
            userService.repeatState = repeatState
        case .search:
            viewController.showSearch()
        }
    }
}

// MARK: - PlayerViewControllerDelegate

extension PlayerController: PlayerViewControllerDelegate {
    func viewController(_ viewController: PlayerViewControlling, prepareForSegue segue: UIStoryboardSegue,
                        sender: Any?) {
        delegate?.controller(self, prepareForSegue: segue, sender: sender)
    }
}
