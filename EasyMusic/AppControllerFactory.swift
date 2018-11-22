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
        let trackManager = TrackManager(userService: userService, authorization: authorization)
        let musicPlayer = MusicPlayer(trackManager: trackManager, remote: remoteCommandCenter,
                                      audioSession: AVAudioSession.sharedInstance())
        let shareManager = ShareManager(appStoreLink: URL(string: "https://itunes.apple.com/app/id1067558718")!)

        let playerController = PlayerController(
            viewController: playerViewController,
            scrubberController: scrubberController,
            infoController: infoController,
            controlsController: controlsController,
            alertController: alertController,
            musicPlayer: musicPlayer,
            userService: userService,
            shareManager: shareManager
        )
        return AppController(playerController: playerController)
    }
}
