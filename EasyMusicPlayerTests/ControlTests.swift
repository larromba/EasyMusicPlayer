@testable import EasyMusic
import MediaPlayer
import XCTest

final class ControlTests: XCTestCase {
    private var controlsViewController: ControlsViewController!
    private var env: AppTestEnvironment!
    private var playerFactory: DummyAudioPlayerFactory!

    override func setUp() {
        super.setUp()
        controlsViewController = .fromStoryboard()
        playerFactory = DummyAudioPlayerFactory()
        env = AppTestEnvironment(controlsViewController: controlsViewController, playerFactory: playerFactory)
    }

    override func tearDown() {
        controlsViewController = nil
        playerFactory = nil
        env = nil
//        UIApplication.shared.keyWindow!.rootViewController = nil
        super.tearDown()
    }

    func test_controls_whenPlayPressed_expectPlaysMusic() {
        // mocks
        env.inject()

        // sut
        XCTAssertTrue(controlsViewController.playButton.fire())

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenPausePressed_expectPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue(controlsViewController.playButton.fire())

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_controls_whenStopPressed_expectStopsMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue(controlsViewController.stopButton.fire())

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.stop4.name) ?? false)
    }

    func test_controls_whenShufflePressed_expectShufflesMusicAndPlays() {
        // mocks
        let library = (0..<100).map { Track(mediaItem: DummyMediaItem(id: $0)) }
        env.setSavedTracks(library.map { DummyMediaItem(track: $0) }, currentTrack: DummyMediaItem(track: library[1]))
        env.inject()

        // sut
        XCTAssertEqual(env.trackManager.tracksResolved, library)
        XCTAssertTrue(controlsViewController.shuffleButton.fire())

        // test
        XCTAssertNotEqual(env.trackManager.tracksResolved, library)
        XCTAssertEqual(env.trackManager.tracksResolved.count, library.count)
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenPrevPressed_expectPlaysPreviousTrack() {
        // mocks
        env.setSavedTracks(library, currentTrack: library[1])
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        XCTAssertTrue(controlsViewController.prevButton.fire())

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 0)
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenNextPressed_expectPlaysNextTrack() {
        // mocks
        env.setSavedTracks(library, currentTrack: library[1])
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        XCTAssertTrue(controlsViewController.nextButton.fire())

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 2)
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenScrubbingMoved_expectChangesPlayLocation() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        env.setSavedTracks(library, currentTrack: library[1])
        env.inject()
        env.setPlaying()

        // sut
        let touches = Set<UITouch>(arrayLiteral: MockTouch(x: env.scrubberViewController.viewWidth / 2))
        scrubberViewController.touchesBegan(touches, with: nil)
        scrubberViewController.touchesMoved(touches, with: nil)
        scrubberViewController.touchesEnded(touches, with: nil)

        // test
        XCTAssertEqual(playerFactory.audioPlayer?.currentTime ?? 0, DummyAsset.normal.playbackDuration / 2)
    }

    func test_controls_whenRepeatAllPressed_expectChangesRepeatState() {
        // mocks
        env.inject()
        env.setRepeatState(.all)

        // sut
        XCTAssertTrue(controlsViewController.repeatButton.fire())

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .none)
    }

    func test_controls_whenRepeatNonePressed_expectChangesRepeatState() {
        // mocks
        env.inject()
        env.setRepeatState(.none)

        // sut
        XCTAssertTrue(controlsViewController.repeatButton.fire())

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .one)
    }

    func test_controls_whenRepeatOnePressed_expectChangesRepeatState() {
        // mocks
        env.inject()
        env.setRepeatState(.one)

        // sut
        XCTAssertTrue( controlsViewController.repeatButton.fire())

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .all)
    }

    func test_controls_whenAppBecomesActive_expectRefreshed() {
        // mocks
        class Delegate: MusicServiceDelegate {
            func musicService(_ service: MusicServicing, threwError error: MusicError) {}
            func musicService(_ service: MusicServicing, changedState state: PlayState) {}
            func musicService(_ service: MusicServicing, changedRepeatState state: RepeatState) {}
            func musicService(_ service: MusicServicing, changedPlaybackTime playbackTime: TimeInterval) {}
        }
        env.inject()
        env.setStopped()
        env.musicService.setDelegate(Delegate()) // detach delegate

        // sut
        env.setPlaying()
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        // test
        XCTAssertEqual(controlsViewController.playButton.backgroundImage(for: .normal), Asset.pauseButton.image)
    }

    func test_controls_whenNotAuthorized_expectSearchDisabled() {
        // mock
        env.setAuthorizationStatus(.denied)
        env.inject()

        // sut
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        // test
        XCTAssertFalse(controlsViewController.searchButton.isEnabled)
    }

    func test_controls_whenAuthorized_expectSearchEnabled() {
        // mock
        env.setAuthorizationStatus(.authorized)
        env.inject()

        // sut
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        // test
        XCTAssertTrue(controlsViewController.searchButton.isEnabled)
    }

    func test_controls_whenSearchPressed_expectSearchView() {
        // mock
        let playerViewController: PlayerViewController = .fromStoryboard()
        env.playerViewController = playerViewController
        env.inject()
        UIApplication.shared.keyWindow!.rootViewController = playerViewController
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        // sut
        XCTAssertTrue(controlsViewController.searchButton.fire())

        // test
        guard let navigationController = playerViewController.presentedViewController as? UINavigationController else {
            XCTFail("expected UINavigationController")
            return
        }
        XCTAssertTrue(navigationController.viewControllers.first is SearchViewController)
    }
}
