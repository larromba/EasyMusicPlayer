import MediaPlayer
import UIKit

enum AppControllerFactory {
    static func make(playerViewController: PlayerViewController) -> AppControlling {
        _ = playerViewController.view // force load of view

        let scrubberController = ScrubberController(viewController: playerViewController.scrubberViewController)
        let infoController = InfoController(viewController: playerViewController.infoViewController,
                                            remoteInfo: MPNowPlayingInfoCenter.default())
        let remoteCommandCenter = MPRemoteCommandCenter.shared()
        let controlsController = ControlsController(viewController: playerViewController.controlsViewController,
                                                    remote: remoteCommandCenter)
        let alertController = AlertController(viewController: playerViewController)

        let dataManager = DataManger(database: UserDefaults.standard)
        let userService = UserService(dataManager: dataManager)
        let authorization = MusicAuthorization(authorizer: MPMediaLibrary.self)
        let playlist = Playlist(authorization: authorization, mediaQuery: MPMediaQuery.self)
        let trackManager = TrackManager(userService: userService, authorization: authorization, playlist: playlist)
        let seeker = Seeker(seekInterval: 0.2)
        let interruptionHandler = MusicInterupptionHandler()
        let clock = Clock(timeInterval: 1.0)
        let playerFactory = AudioPlayerFactory()
        let musicService = MusicService(trackManager: trackManager, remote: remoteCommandCenter,
                                       audioSession: AVAudioSession.sharedInstance(), authorization: authorization,
                                       seeker: seeker, interruptionHandler: interruptionHandler, clock: clock,
                                       playerFactory: playerFactory)

        let playerController = PlayerController(
            viewController: playerViewController,
            scrubberController: scrubberController,
            infoController: infoController,
            controlsController: controlsController,
            alertController: alertController,
            musicService: musicService,
            userService: userService
        )
        return AppController(playerController: playerController)
    }
}
