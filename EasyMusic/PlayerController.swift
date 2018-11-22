import UIKit

protocol PlayerControlling {
    // 🦄
}

final class PlayerController: PlayerControlling {
    private let viewController: PlayerViewControlling
    private let scrubberController: ScrubberControlling
    private let infoController: InfoControlling
    private let controlsController: ControlsControlling
    private let alertController: AlertControlling
    private let musicPlayer: MusicPlaying
    private let shareManager: ShareManaging
    private let userService: UserServicing
    private var isUserScrobbling: Bool = false

    init(viewController: PlayerViewControlling,
         scrubberController: ScrubberControlling,
         infoController: InfoControlling,
         controlsController: ControlsController,
         alertController: AlertControlling,
         musicPlayer: MusicPlaying,
         userService: UserServicing,
         shareManager: ShareManaging) {
        self.viewController = viewController
        self.scrubberController = scrubberController
        self.infoController = infoController
        self.controlsController = controlsController
        self.alertController = alertController
        self.musicPlayer = musicPlayer
        self.userService = userService
        self.shareManager = shareManager
        setup()
    }

    // MARK: - private

    private func setup() {
        // delegate
        scrubberController.setDelegate(self)
        musicPlayer.setDelegate(delegate: self)
        viewController.controlsViewController.setDelegate(self)

        // view state
        if let repeatMode = userService.repeatMode {
            musicPlayer.repeatState = repeatMode
            controlsController.repeatButtonState = repeatMode
        }
        viewController.viewState = PlayerViewState(appVersion: Bundle.appVersion)

        // notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }

    private func updateSeekingControls() {
        if musicPlayer.repeatState == .all {
            controlsController.setPreviousIsEnabled(true)
            controlsController.setNextIsEnabled(true)
            return
        }

        let trackNumber = musicPlayer.currentTrackNumber
        if trackNumber == 0 {
            controlsController.setPreviousIsEnabled(false)
            controlsController.setSeekBackwardsIsEnabled(true)
        }
        if trackNumber == (musicPlayer.numOfTracks - 1) {
            controlsController.setNextIsEnabled(false)
            controlsController.setSeekForwardsIsEnabled(true)
        }
    }

    // MARK: - notification

    @objc
    private func applicationDidBecomeActive() {
        // if play button is showing pause image, but the player isn't playing, then somthing went horribly wrong...
        // so stop (reset) the player
        guard let playState = controlsController.playButtonState else { return }
        if playState == .pause && !musicPlayer.isPlaying {
            musicPlayer.stop()
        }
    }
}

// MARK: - MusicPlayerDelegate

extension PlayerController: MusicPlayerDelegate {
    func musicPlayer(_ sender: MusicPlayer, changedState state: MusicPlayerState) {
        switch state {
        case .playing:
            controlsController.setControlsPlaying()
            infoController.setInfoFromTrack(sender.currentTrack.resolved)
            infoController.setTrackPosition((sender.currentTrackNumber + 1), totalTracks: sender.numOfTracks)
            scrubberController.setIsUserInteractionEnabled(true)
            updateSeekingControls()
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
            alertController.showAlert(.finished)
        }
    }

    func musicPlayer(_ sender: MusicPlayer, changedPlaybackTime playbackTime: TimeInterval) {
        guard !isUserScrobbling else { return }

        let duration = musicPlayer.currentTrack.playbackDuration
        let percentage = duration > 0 ? playbackTime / duration : 0

        scrubberController.moveScrubber(percentage: Float(percentage))
        infoController.setTime(playbackTime, duration: duration)
    }

    func musicPlayer(_ player: MusicPlayer, threwError error: MusicError) {
        switch error {
        case .noMusic:
            infoController.clearInfo()
            alertController.showAlert(.noMusic)
        case .noVolume:
            alertController.showAlert(.noVolume)
        case .avError:
            alertController.showAlert(.trackError(title: player.currentTrack.resolved.title))
        case .decode, .playerInit:
            player.skip()
        case .authorization:
            alertController.showAlert(.authError)
        }
    }
}

// MARK: - ScrubberControllerDelegates

extension PlayerController: ScrubberControllerDelegate {
    func scrubberController(_ controller: ScrubberControlling, touchMovedToPercentage percentage: Float) {
        isUserScrobbling = true
        let duration = musicPlayer.currentTrack.playbackDuration
        let time = duration * TimeInterval(percentage)
        infoController.setTime(time, duration: duration)
    }

    func scrubberController(_ controller: ScrubberControlling, touchEndedAtPercentage percentage: Float) {
        let duration = musicPlayer.currentTrack.playbackDuration
        let time = duration * TimeInterval(percentage)
        infoController.setTime(time, duration: duration)
        musicPlayer.time = time
        isUserScrobbling = false
    }
}

// MARK: - ControlsViewDelegate

extension PlayerController: ControlsViewDelegate {
    func controlsViewController(_ viewController: ControlsViewControlling, pressedPlay play: UIButton) {
        play.pulse()
        if musicPlayer.isPlaying {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
        }
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedStop stop: UIButton) {
        stop.pulse()
        musicPlayer.stop()
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedPrev prev: UIButton) {
        prev.pulse()
        musicPlayer.previous()
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedNext next: UIButton) {
        next.pulse()
        musicPlayer.next()
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedShuffle shuffle: UIButton) {
        shuffle.pulse()
        shuffle.spin()

        musicPlayer.stop()
        musicPlayer.shuffle()
        musicPlayer.play()
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedShare share: UIButton) {
        shareManager.shareTrack(
            musicPlayer.currentTrack.resolved,
            presenter: self.viewController.casted,
            sender: viewController.shareButton,
            completion: { [weak self] (result: ShareResult, _: String?) in
                switch result {
                case .error:
                    self?.alertController.showAlert(.shareError)
                default:
                    break
                }
            })
    }

    func controlsViewController(_ viewController: ControlsViewControlling, pressedRepeat repeat: UIButton) {
        guard let viewState = viewController.viewState else { return }
        let currentRepeatState = viewState.repeatButton.state
        let nextRepeatState = currentRepeatState.next()

        // update
        let repeatButtonState = viewState.repeatButton.copy(state: nextRepeatState)
        viewController.viewState = viewController.viewState?.copy(repeatButton: repeatButtonState)
        musicPlayer.repeatState = nextRepeatState
        if musicPlayer.isPlaying {
            updateSeekingControls()
        }

        // save
        userService.repeatMode = nextRepeatState
    }
}

// MARK: - PlayerViewControlling

private extension PlayerViewControlling {
    var casted: UIViewController {
        guard let viewController = self as? UIViewController else {
            assertionFailure("expected UIViewController")
            return UIViewController()
        }
        return viewController
    }
}
