@testable import EasyMusic
import Foundation
import MediaPlayer

extension PlayerController {
    static func testable(viewController: PlayerViewControlling = MockPlayerViewController(),
                         scrubberController: ScrubberControlling = MockScrubberController(),
                         infoController: InfoControlling = MockInfoController(),
                         controlsController: ControlsControlling = MockControlsController(),
                         alertController: AlertControlling = MockAlertController(),
                         musicService: MusicServicing = MockMusicService(),
                         userService: UserServicing = MockUserService()) -> PlayerControlling {
        return PlayerController(
            viewController: viewController,
            scrubberController: scrubberController,
            infoController: infoController,
            controlsController: controlsController,
            alertController: alertController,
            musicService: musicService,
            userService: userService
        )
    }
}

extension MusicService {
    static func testable(trackManager: TrackManaging = MockTrackManager(),
                         remote: RemoteControlling = MockRemoteCommandCenter(),
                         audioSession: AudioSessioning = MockAudioSession(),
                         authorization: Authorizable = MockAuthorizer(),
                         seeker: Seekable = MockSeeker(),
                         interruptionHandler: MusicInterupptionHandling = MockMusicInterupptionHandler(),
                         clock: Clocking = MockClock(),
                         playerFactory: AudioPlayerFactoring = MockAudioPlayerFactory()) -> MusicServicing {
        return MusicService(trackManager: trackManager,
                            remote: remote,
                            audioSession: audioSession,
                            authorization: authorization,
                            seeker: seeker,
                            interruptionHandler: interruptionHandler,
                            clock: clock,
                            playerFactory: playerFactory)
    }
}
