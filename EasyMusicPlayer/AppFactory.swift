import MediaPlayer
import UIKit

enum AppFactory {
    // swiftlint:disable function_body_length
    static func make(playerViewController: PlayerViewController) -> Appable {
        _ = playerViewController.view // force load of view
        let remote = Remote()
        let remoteInfo = MPNowPlayingInfoCenter.default()
        let scrubberController = ScrubberController(
            viewController: playerViewController.scrubberViewController,
            remote: remote
        )
        let infoController = InfoController(
            viewController: playerViewController.infoViewController,
            remoteInfo: remoteInfo)

        let controlsController = ControlsController(
            viewController: playerViewController.controlsViewController,
            remote: remote
        )
        let dataManager = DataManger(userDefaults: UserDefaults.standard)
        let userService = UserService(dataManager: dataManager)
        let authorization = MusicAuthorization(authorizer: MPMediaLibrary.self)
        let playlist = Playlist(authorization: authorization, mediaQuery: MPMediaQuery.self)
        let trackManager = TrackManager(userService: userService, authorization: authorization, playlist: playlist)
        let seeker = Seeker(seekInterval: 0.2)
        let audioSession = AVAudioSession.sharedInstance()
        let interruptionHandler = MusicInterruptionHandler(session: audioSession)
        let clock = Clock(timeInterval: 1.0)
        let playerFactory = AudioPlayerFactory()
        let musicService = MusicService(
            trackManager: trackManager,
            remote: remote,
            audioSession: audioSession,
            authorization: authorization,
            seeker: seeker,
            interruptionHandler: interruptionHandler,
            clock: clock,
            playerFactory: playerFactory
        )
        let playerController = PlayerController(
            viewController: playerViewController,
            scrubberController: scrubberController,
            infoController: infoController,
            controlsController: controlsController,
            musicService: musicService,
            userService: userService,
            authorization: authorization
        )
        let playerCoordinator = PlayerCoordinator(
            playerController: playerController,
            alertController: AlertController(presenter: playerViewController)
        )
        let search = Search(authorization: authorization, trackManager: trackManager)
        let searchController = SearchController(search: search)
        let searchCoordinator = SearchCoordinator(searchController: searchController)
        let router = AppRouter(playerCoordinator: playerCoordinator, searchCoordinator: searchCoordinator)
        return App(router: router)
    }
}
