import UIKit

// sourcery: name = PlayerController
protocol PlayerControlling: Mockable {
    // 🦄
}

final class PlayerController: PlayerControlling {
    private let viewController: PlayerViewControlling
    private let scrubberController: ScrubberControlling
    private let infoController: InfoControlling
    private let controlsController: ControlsControlling
    private let alertController: AlertControlling
    private let musicService: MusicServicing
    private let userService: UserServicing
    private var isUserScrubbing: Bool = false

    init(viewController: PlayerViewControlling,
         scrubberController: ScrubberControlling,
         infoController: InfoControlling,
         controlsController: ControlsControlling,
         alertController: AlertControlling,
         musicService: MusicServicing,
         userService: UserServicing) {
        self.viewController = viewController
        self.scrubberController = scrubberController
        self.infoController = infoController
        self.controlsController = controlsController
        self.alertController = alertController
        self.musicService = musicService
        self.userService = userService
        setup()
    }

    // MARK: - private

    private func setup() {
        scrubberController.setDelegate(self)
        controlsController.setDelegate(self)
        musicService.setDelegate(delegate: self)

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
        if playButtonState == musicService.state.playState {
            musicService.stop()
        }
    }
}

// MARK: - MusicServiceDelegate

extension PlayerController: MusicServiceDelegate {
    func musicService(_ sender: MusicService, changedState state: PlayState) {
        controlsController.setMusicServiceState(sender.state)
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

    func musicService(_ sender: MusicService, changedPlaybackTime playbackTime: TimeInterval) {
        guard !isUserScrubbing else { return }

        let duration = musicService.state.currentTrack.playbackDuration
        let percentage = duration > 0 ? playbackTime / duration : 0

        scrubberController.moveScrubber(percentage: Float(percentage))
        infoController.setTime(playbackTime, duration: duration)
    }

    func musicService(_ service: MusicService, threwError error: MusicError) {
        switch error {
        case .noMusic:
            infoController.clearInfo()
            alertController.showAlert(.noMusic)
        case .noVolume:
            alertController.showAlert(.noVolume)
        case .avError:
            alertController.showAlert(.trackError(title: service.state.currentTrack.resolved.title))
        case .decode, .playerInit:
            service.skip()
        case .authorization:
            alertController.showAlert(.authError)
        }
    }
}

// MARK: - ScrubberControllerDelegates

extension PlayerController: ScrubberControllerDelegate {
    func scrubberController(_ controller: ScrubberControlling, touchMovedToPercentage percentage: Float) {
        isUserScrubbing = true
        let duration = musicService.state.currentTrack.playbackDuration
        let time = duration * TimeInterval(percentage)
        infoController.setTime(time, duration: duration)
    }

    func scrubberController(_ controller: ScrubberControlling, touchEndedAtPercentage percentage: Float) {
        let duration = musicService.state.currentTrack.playbackDuration
        let time = duration * TimeInterval(percentage)
        infoController.setTime(time, duration: duration)
        musicService.setTime(time)
        isUserScrubbing = false
    }
}

// MARK: - ControlsDelegate

extension PlayerController: ControlsDelegate {
    func controlsControllerPressedPlay(_ controller: ControlsControlling) {
        if musicService.state.isPlaying {
            musicService.pause()
        } else {
            musicService.play()
        }
    }

    func controlsControllerPressedStop(_ controller: ControlsControlling) {
        musicService.stop()
    }

    func controlsControllerPressedPrev(_ controller: ControlsControlling) {
        musicService.previous()
    }

    func controlsControllerPressedNext(_ controller: ControlsControlling) {
        musicService.next()
    }

    func controlsControllerPressedShuffle(_ controller: ControlsControlling) {
        musicService.stop()
        musicService.shuffle()
        musicService.play()
    }

    func controlsControllerPressedRepeat(_ controller: ControlsControlling) {
        guard let repeatState = controller.repeatButtonState else { return }
        musicService.setRepeatState(repeatState)
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
