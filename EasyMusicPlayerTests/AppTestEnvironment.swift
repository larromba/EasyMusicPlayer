@testable import EasyMusic
import Foundation
import MediaPlayer

let defaultTracks: [MPMediaItem] = [.mock(id: 0), .mock(id: 1), .mock(id: 2)]

final class AppTestEnvironment {
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
         // TestAudioPlayerFactory is not defined via protocol for ease. There's no need to send in another factory
         playerFactory: TestAudioPlayerFactory = TestAudioPlayerFactory(),
         userDefaults: UserDefaultable = MockUserDefaults(),
         mediaQueryType: MediaQueryable.Type = MockMediaQuery.self) {
        AppTestEnvironment.resetAllStaticMocks()
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

    func preparePlayError() {
        playerFactory.didPlay = false
    }

    func setPlaying() {
        musicService.play()
    }

    func next() {
        musicService.next()
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

    func shuffle() {
        musicService.shuffle()
    }

    func setRepeatState(_ repeatState: RepeatState) {
        controlsController.setRepeatState(repeatState)
    }

    func setCurrentTime(_ time: TimeInterval) {
        playerFactory.currentTime = time
    }

    func setAuthorizationStatus(_ authorizationStatus: MPMediaLibraryAuthorizationStatus) {
        let authorizerType = MockMediaLibrary.self
        authorizerType.actions.set(returnValue: authorizationStatus, for: MockMediaLibrary.authorizationStatus1.name)
        self.authorizerType = authorizerType
    }

    func setLibraryTracks(_ tracks: [MPMediaItem]) {
        let mediaQueryType = MockMediaQuery.self
        mediaQueryType.actions.set(returnValue: TestMediaQuery(items: tracks), for: MockMediaQuery.songs1.name)
        self.mediaQueryType = mediaQueryType
    }

    func setSavedTracks(_ tracks: [MPMediaItem], currentTrack: MPMediaItem?, isAvailableInLibrary: Bool = true) {
        if isAvailableInLibrary {
            setLibraryTracks(tracks)
        }
        let userDefaults = UserDefaults(suiteName: UUID().uuidString)!
        let dataManager = DataManger(userDefaults: userDefaults)
        let userService = UserService(dataManager: dataManager)
        userService.trackIDs = tracks.map { $0.persistentID }
        userService.currentTrackID = currentTrack?.persistentID
        self.userDefaults = userDefaults
    }

    func setOutputVolume(_ volume: Float) {
        let audioSession = MockAudioSession()
        audioSession.outputVolume = volume
        self.audioSession = audioSession
    }

    // MARK: - private

    private static func resetAllStaticMocks() {
        // TODO: update mockable stencil to remove invocation history
        MockMediaLibrary.actions.set(returnValue: MPMediaLibraryAuthorizationStatus.authorized,
                                     for: MockMediaLibrary.authorizationStatus1.name)
        MockMediaQuery.actions.set(returnValue: TestMediaQuery(items: [MockMediaItem()]),
                                   for: MockMediaQuery.songs1.name)
    }
}

extension AppTestEnvironment: TestEnvironment {
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
}