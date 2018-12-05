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
    private let userService: UserServicing
    private var isUserScrobbling: Bool = false

    init(viewController: PlayerViewControlling,
         scrubberController: ScrubberControlling,
         infoController: InfoControlling,
         controlsController: ControlsController,
         alertController: AlertControlling,
         musicPlayer: MusicPlaying,
         userService: UserServicing) {
        self.viewController = viewController
        self.scrubberController = scrubberController
        self.infoController = infoController
        self.controlsController = controlsController
        self.alertController = alertController
        self.musicPlayer = musicPlayer
        self.userService = userService
        setup()
    }

    // MARK: - private

    private func setup() {
        scrubberController.setDelegate(self)
        controlsController.setDelegate(self)
        musicPlayer.setDelegate(delegate: self)

        if let repeatMode = userService.repeatState {
            musicPlayer.setRepeatState(repeatMode)
            controlsController.setRepeatState(repeatMode)
        }
        viewController.viewState = PlayerViewState(appVersion: Bundle.appVersion)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
    }

    // MARK: - notification

    @objc
    private func applicationDidBecomeActive() {
        // if play button is no longr in sync (by being equal) to play state, stop the player.
        // e.g. if play button is showing pause image (indicating the player is playing), but the player isn't playing,
        // then somthing went horribly wrong...
        guard let playButtonState = controlsController.playButtonState else { return }
        if playButtonState == musicPlayer.state.playState {
            musicPlayer.stop()
        }
    }
}

// MARK: - MusicPlayerDelegate

extension PlayerController: MusicPlayerDelegate {
    func musicPlayer(_ sender: MusicPlayer, changedState state: PlayState) {
        controlsController.setMusicPlayerState(sender.state)
        switch state {
        case .playing:
            controlsController.setControlsPlaying()
            infoController.setInfoFromTrack(sender.state.currentTrack.resolved)
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
            alertController.showAlert(.finished)
        }
    }

    func musicPlayer(_ sender: MusicPlayer, changedPlaybackTime playbackTime: TimeInterval) {
        guard !isUserScrobbling else { return }

        let duration = musicPlayer.state.currentTrack.playbackDuration
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
            alertController.showAlert(.trackError(title: player.state.currentTrack.resolved.title))
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
        let duration = musicPlayer.state.currentTrack.playbackDuration
        let time = duration * TimeInterval(percentage)
        infoController.setTime(time, duration: duration)
    }

    func scrubberController(_ controller: ScrubberControlling, touchEndedAtPercentage percentage: Float) {
        let duration = musicPlayer.state.currentTrack.playbackDuration
        let time = duration * TimeInterval(percentage)
        infoController.setTime(time, duration: duration)
        musicPlayer.setTime(time)
        isUserScrobbling = false
    }
}

// MARK: - ControlsDelegate

extension PlayerController: ControlsDelegate {
    func controlsControllerPressedPlay(_ controller: ControlsControlling) {
        if musicPlayer.state.isPlaying {
            musicPlayer.pause()
        } else {
            musicPlayer.play()
        }
    }

    func controlsControllerPressedStop(_ controller: ControlsControlling) {
        musicPlayer.stop()
    }

    func controlsControllerPressedPrev(_ controller: ControlsControlling) {
        musicPlayer.previous()
    }

    func controlsControllerPressedNext(_ controller: ControlsControlling) {
        musicPlayer.next()
    }

    func controlsControllerPressedShuffle(_ controller: ControlsControlling) {
        musicPlayer.stop()
        musicPlayer.shuffle()
        musicPlayer.play()
    }

    func controlsControllerPressedRepeat(_ controller: ControlsControlling) {
        guard let repeatState = controller.repeatButtonState else { return }
        musicPlayer.setRepeatState(repeatState)
        userService.repeatState = repeatState
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
