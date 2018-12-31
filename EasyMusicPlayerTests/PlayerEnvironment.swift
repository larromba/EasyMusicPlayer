@testable import EasyMusic
import Foundation
import MediaPlayer

final class PlayerEnvironment: TestEnvironment {
    var playerViewController: PlayerViewControlling
    var scrubberViewController: ScrubberViewControlling
    var remote: RemoteControlling
    var remoteInfo: NowPlayingInfoCentering
    var controlsViewController: ControlsViewControlling
    var alertPresenter: Presentable
    var audioSession: AudioSessioning
    var seeker: Seekable
    var interruptionHandler: MusicInterruptionHandling
    var clock: Clocking
    var playerFactory: TestAudioPlayerFactory // using instance name rather than protocol name to make testing easier
    var userDefaults: UserDefaultable
    var mediaQueryType: MediaQueryable.Type
    var infoViewController: InfoViewControlling
    var authorizerType: MediaLibraryAuthorizable.Type

    private(set) var playlist: Playlistable!
    private(set) var trackManager: TrackManaging!
    private(set) var musicService: MusicServicing!
    private(set) var dataManager: DataManaging!
    private(set) var userService: UserServicing!
    private(set) var playerController: PlayerControlling!
    private(set) var controlsController: ControlsControlling!
    private(set) var alertController: AlertControlling!
    private(set) var infoController: InfoControlling!
    private(set) var scrubberController: ScrubberControlling!
    private(set) var authorization: Authorization!

    init(playerViewController: PlayerViewControlling = MockPlayerViewController(),
         scrubberViewController: ScrubberViewControlling = MockScrubberViewController(),
         remote: RemoteControlling = MockRemoteCommandCenter(),
         infoViewController: InfoViewControlling = MockInfoViewController(),
         remoteInfo: NowPlayingInfoCentering = MockNowPlayingInfoCenter(),
         controlsViewController: ControlsViewControlling = MockControlsViewController(),
         alertPresenter: Presentable = UIViewController(),
         audioSession: AudioSessioning = MockAudioSession(),
         authorizerType: MediaLibraryAuthorizable.Type = MockMediaLibrary.self,
         seeker: Seekable = MockSeeker(),
         interruptionHandler: MusicInterruptionHandling = MockMusicInterruptionHandler(),
         clock: Clocking = MockClock(),
         playerFactory: TestAudioPlayerFactory = TestAudioPlayerFactory(), // TODO: change to protocol?
         userDefaults: UserDefaultable = MockUserDefaults(),
         mediaQueryType: MediaQueryable.Type = MockMediaQuery.self) {
        self.playerViewController = playerViewController
        self.scrubberViewController = scrubberViewController
        self.remote = remote
        self.infoViewController = infoViewController
        self.remoteInfo = remoteInfo
        self.controlsViewController = controlsViewController
        self.alertPresenter = alertPresenter
        self.audioSession = audioSession
        self.authorizerType = authorizerType
        self.seeker = seeker
        self.interruptionHandler = interruptionHandler
        self.clock = clock
        self.playerFactory = playerFactory
        self.userDefaults = userDefaults
        self.mediaQueryType = mediaQueryType
    }

    func inject() {
        authorization = MusicAuthorization(authorizer: authorizerType)
        playlist = Playlist(authorization: authorization, mediaQuery: mediaQueryType)
        dataManager = DataManger(userDefaults: userDefaults)
        userService = UserService(dataManager: dataManager)
        trackManager = TrackManager(userService: userService, authorization: authorization, playlist: playlist)
        musicService = MusicService(trackManager: trackManager, remote: remote, audioSession: audioSession,
                                    authorization: authorization, seeker: seeker,
                                    interruptionHandler: interruptionHandler, clock: clock,
                                    playerFactory: playerFactory)
        scrubberController = ScrubberController(viewController: scrubberViewController, remote: remote)
        infoController = InfoController(viewController: infoViewController, remoteInfo: remoteInfo)
        controlsController = ControlsController(viewController: controlsViewController, remote: remote)
        alertController = AlertController(presenter: alertPresenter)
        playerController = PlayerController(viewController: playerViewController,
                                            scrubberController: scrubberController,
                                            infoController: infoController,
                                            controlsController: controlsController,
                                            alertController: alertController,
                                            musicService: musicService,
                                            userService: userService)
    }

    func setPlaying() {
        musicService.play()
    }

    func setPaused() {
        musicService.play()
        playerFactory.audioPlayer?.isPlaying = false
        musicService.pause()
    }

    func setStopped() {
        musicService.play()
        playerFactory.audioPlayer?.isPlaying = false
        musicService.stop()
    }

    func setRepeatState(_ repeatState: RepeatState) {
        controlsController.setRepeatState(repeatState)
    }

    func setCurrentTime(_ time: TimeInterval) {
        playerFactory.currentTime = time
    }
}

// TODO: split?
final class PlayerEnvironmentHelper {
    let tracks: [MPMediaItem]
    let currentTrackID: MPMediaEntityPersistentID
    let authorizationStatus: MPMediaLibraryAuthorizationStatus
    let volume: Float
    let mediaQueryType: MediaQueryable.Type
    let userDefaults: UserDefaultable
    let authorizerType: MediaLibraryAuthorizable.Type
    let audioSession: AudioSessioning

    init(tracks: [MPMediaItem] = [.mock(id: 0), .mock(id: 1), .mock(id: 2)],
         currentTrackID: MPMediaEntityPersistentID = 1,
         authorizationStatus: MPMediaLibraryAuthorizationStatus = .authorized, volume: Float = 1) {
        self.tracks = tracks
        self.currentTrackID = currentTrackID
        self.authorizationStatus = authorizationStatus
        self.volume = volume

        mediaQueryType = MockMediaQuery.self
        MockMediaQuery.actions.set(returnValue: TestMediaQuery(items: tracks), for: MockMediaQuery.songs1.name)

        let userDefaults = TestUserDefaults()
        userDefaults.trackIDs = tracks.map { $0.persistentID }
        userDefaults.currentTrackID = currentTrackID
        self.userDefaults = userDefaults

        let authorizerType = MockMediaLibrary.self
        authorizerType.actions.set(returnValue: authorizationStatus, for: MockMediaLibrary.authorizationStatus1.name)
        self.authorizerType = authorizerType

        let audioSession = MockAudioSession()
        audioSession.outputVolume = volume
        self.audioSession = audioSession
    }
}
