@testable import EasyMusic
import Foundation
import MediaPlayer

final class PlayerEnvironment: TestEnvironment {
    let playlist = MockPlaylist()
    let playerFactory: TestAudioPlayerFactory
    let authorization = MusicAuthorization(authorizer: MockMusicAuthorizer.self)
    let trackManager: TrackManaging
    let remote: RemoteControlling
    let remoteInfo: NowPlayingInfoCentering
    let userService: UserServicing
    let audioSession = MockAudioSession()
    let alertController: AlertControlling
    lazy var musicService = MusicService.testable(trackManager: trackManager, remote: remote,
                                                  audioSession: audioSession, authorization: authorization,
                                                  seeker: Seeker(seekInterval: 1.0),
                                                  interruptionHandler: MusicInterupptionHandler(),
                                                  playerFactory: playerFactory)
    let controlsViewController = ControlsViewController.fromStoryboard
    lazy var controlsController = ControlsController(viewController: controlsViewController, remote: remote)
    let scrubberViewController = ScrubberViewController.fromStoryboard
    lazy var scrubberController = ScrubberController(viewController: scrubberViewController, remote: remote)
    let infoViewController = InfoViewController.fromStoryboard
    lazy var infoController = InfoController(viewController: infoViewController, remoteInfo: remoteInfo)
    var playerController: PlayerControlling?
    let alertViewController: UIViewController

    init(authorizationStatus: MPMediaLibraryAuthorizationStatus = .authorized,
         isPlaying: Bool = true, didPrepare: Bool = true, didPlay: Bool = true, outputVolume: Float = 1.0,
         currentTime: TimeInterval = 0, duration: TimeInterval = 10, repeatState: RepeatState = .none,
         trackID: MPMediaEntityPersistentID = 0,
         mediaItems: [MPMediaItem] = [.mock(id: 0), .mock(id: 1), .mock(id: 2)],
         remote: RemoteControlling = MPRemoteCommandCenter.shared(),
         remoteInfo: NowPlayingInfoCentering = MPNowPlayingInfoCenter.default(),
         userService: UserServicing = MockUserService(),
         alertViewController: UIViewController = UIViewController()) {
        self.remote = remote
        self.remoteInfo = remoteInfo
        self.userService = userService
        self.alertViewController = alertViewController
        playerFactory = TestAudioPlayerFactory(isPlaying: isPlaying, didPrepare: didPrepare, didPlay: didPlay,
                                               currentTime: currentTime, duration: duration)
        userService.currentTrackID = trackID
        userService.trackIDs = mediaItems.map { $0.persistentID }
        userService.repeatState = repeatState
        playlist.actions.set(returnValue: mediaItems, for: MockPlaylist.find2.name)
        playlist.actions.set(returnValue: mediaItems, for: MockPlaylist.create1.name)
        MockMusicAuthorizer.actions.set(returnValue: authorizationStatus,
                                        for: MockMusicAuthorizer.authorizationStatus1.name)
        audioSession.outputVolume = outputVolume
        trackManager = TrackManager(userService: userService, authorization: authorization, playlist: playlist)
        alertController = AlertController(viewController: alertViewController)
    }

    func inject() {
        playerController = PlayerController.testable(scrubberController: scrubberController,
                                                     infoController: infoController,
                                                     controlsController: controlsController,
                                                     alertController: alertController,
                                                     musicService: musicService,
                                                     userService: userService)
    }
}
