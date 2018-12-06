@testable import EasyMusic
import Foundation
import MediaPlayer

final class MusicControlEnvironment: TestEnvironment {
    let playlist = MockPlaylist()
    let playerFactory: TestAudioPlayerFactory
    let authorization = MusicAuthorization(authorizer: MockMusicAuthorizer.self)
    let trackManager: TrackManaging
    let remote: RemoteControlling
    let userService = MockUserService()
    lazy var musicService = MusicService.testable(trackManager: trackManager, remote: remote,
                                                  authorization: authorization, seeker: Seeker(seekInterval: 1.0),
                                                  playerFactory: playerFactory)
    let controlsViewController = ControlsViewController.fromStoryboard
    lazy var controlsController = ControlsController(viewController: controlsViewController, remote: remote)
    let scrubberViewController = ScrubberViewController.fromStoryboard
    lazy var scrubberController = ScrubberController(viewController: scrubberViewController)
    var playerController: PlayerControlling?

    init(isPlaying: Bool = true, didPrepare: Bool = true,
         didPlay: Bool = true, currentTime: TimeInterval = 0, duration: TimeInterval = 10,
         repeatState: RepeatState = .none, trackID: MPMediaEntityPersistentID = 0,
         trackIDs: [MPMediaEntityPersistentID] = [0, 1, 2],
         remote: RemoteControlling = MPRemoteCommandCenter.shared()) {
        self.remote = remote
        playerFactory = TestAudioPlayerFactory(isPlaying: isPlaying, didPrepare: didPrepare, didPlay: didPlay,
                                               currentTime: currentTime, duration: duration)
        userService.currentTrackID = trackID
        userService.trackIDs = trackIDs
        userService.repeatState = repeatState
        playlist.actions.set(returnValue: trackIDs.map { _ in MPMediaItem.mock }, for: MockPlaylist.find2.name)
        playlist.actions.set(returnValue: trackIDs.map { _ in MPMediaItem.mock }, for: MockPlaylist.create1.name)
        trackManager = TrackManager(userService: userService, authorization: authorization, playlist: playlist)
    }

    func inject() {
        playerController = PlayerController.testable(scrubberController: scrubberController,
                                                     controlsController: controlsController,
                                                     musicService: musicService,
                                                     userService: userService)
    }
}
