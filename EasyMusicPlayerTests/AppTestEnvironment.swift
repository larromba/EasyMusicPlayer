@testable import EasyMusic
import Foundation
import MediaPlayer

let library = [DummyMediaItem(id: 0), DummyMediaItem(id: 1), DummyMediaItem(id: 2)]

final class AppTestEnvironment {
    var playerViewController: PlayerViewControlling
    var scrubberViewController: ScrubberViewControlling
    var remote: Remoting
    var remoteInfo: NowPlayingInfoCentering
    var controlsViewController: ControlsViewControlling
    var alertPresenter: Presentable
    var audioSession: AudioSessioning
    var seeker: Seekable
    var interruptionHandler: MusicInterruptionHandling
    var clock: Clocking
    var playerFactory: AudioPlayerFactoring
    var userDefaults: UserDefaultable
    var mediaQueryType: MediaQueryable.Type
    var infoViewController: InfoViewControlling
    var authorizerType: MediaLibraryAuthorizable.Type

    private(set) var playlist: Playlistable!
    private(set) var trackManager: TrackManaging!
    private(set) var musicService: MusicServicing!
    private(set) var dataManager: DataManaging!
    private(set) var userService: UserServicing!
    private(set) var playerCoordinator: PlayerCoordinating!
    private(set) var playerController: PlayerControlling!
    private(set) var controlsController: ControlsControlling!
    private(set) var alertController: AlertControlling!
    private(set) var infoController: InfoControlling!
    private(set) var scrubberController: ScrubberControlling!
    private(set) var authorization: Authorization!
    private(set) var search: Searchable!
    private(set) var searchController: SearchControlling!
    private(set) var searchCoordinator: SearchCoordinating!
    private(set) var appRouter: AppRouting!

    init(playerViewController: PlayerViewControlling = MockPlayerViewController(),
         scrubberViewController: ScrubberViewControlling = MockScrubberViewController(),
         remote: Remoting = Remote(),
         infoViewController: InfoViewControlling = MockInfoViewController(),
         remoteInfo: NowPlayingInfoCentering = MockNowPlayingInfoCenter(),
         controlsViewController: ControlsViewControlling = MockControlsViewController(),
         alertPresenter: Presentable = UIViewController(),
         audioSession: AudioSessioning = MockAudioSession(),
         authorizerType: MediaLibraryAuthorizable.Type = MockMediaLibrary.self,
         seeker: Seekable = MockSeeker(),
         interruptionHandler: MusicInterruptionHandling = MockMusicInterruptionHandler(),
         clock: Clocking = MockClock(),
         playerFactory: AudioPlayerFactoring = DummyAudioPlayerFactory(),
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

    func setPlaying() {
        musicService.play()
    }

    func prev() {
        musicService.previous()
    }

    func next() {
        musicService.next()
    }

    func setPaused() {
        musicService.play()
        musicService.pause()
    }

    func setStopped() {
        musicService.play()
        musicService.stop()
    }

    func shuffle() {
        musicService.shuffle()
    }

    func setRepeatState(_ repeatState: RepeatState) {
        controlsController.setRepeatState(repeatState)
    }

    func setAuthorizationStatus(_ authorizationStatus: MPMediaLibraryAuthorizationStatus) {
        let authorizerType = MockMediaLibrary.self
        authorizerType.actions.set(returnValue: authorizationStatus, for: MockMediaLibrary.authorizationStatus1.name)
        self.authorizerType = authorizerType
    }

    func setLibraryTracks(_ tracks: [MPMediaItem]) {
        let mediaQueryType = MockMediaQuery.self
        mediaQueryType.actions.set(returnValue: DummyMediaQuery(items: tracks), for: MockMediaQuery.songs1.name)
        self.mediaQueryType = mediaQueryType
    }

    func setSavedTracks(_ tracks: [MPMediaItem], currentTrack: MPMediaItem, isAvailableInLibrary: Bool = true) {
        if isAvailableInLibrary {
            setLibraryTracks(tracks)
        }
        let userDefaults = UserDefaults(suiteName: UUID().uuidString)!
        let dataManager = DataManger(userDefaults: userDefaults)
        let userService = UserService(dataManager: dataManager)
        userService.trackIDs = tracks.map { $0.persistentID }
        userService.currentTrackID = currentTrack.persistentID
        self.userDefaults = userDefaults
    }

    func setOutputVolume(_ volume: Float) {
        let audioSession = MockAudioSession()
        audioSession.outputVolume = volume
        self.audioSession = audioSession
    }

    // MARK: - private

    private static func resetAllStaticMocks() {
        MockMediaLibrary.invocations.clear()
        MockMediaLibrary.actions.set(returnValue: MPMediaLibraryAuthorizationStatus.authorized,
                                     for: MockMediaLibrary.authorizationStatus1.name)
        MockMediaQuery.invocations.clear()
        MockMediaQuery.actions.set(returnValue: DummyMediaQuery(items: library),
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
                                            musicService: musicService,
                                            userService: userService,
                                            authorization: authorization)
        playerCoordinator = PlayerCoordinator(playerController: playerController, alertController: alertController)
        search = Search(authorization: authorization, trackManager: trackManager)
        searchController = SearchController(search: search)
        searchCoordinator = SearchCoordinator(searchController: searchController)
        appRouter = AppRouter(playerCoordinator: playerCoordinator, searchCoordinator: searchCoordinator)
    }
}
