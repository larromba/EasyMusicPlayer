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
        super.tearDown()
    }

    func test_controls_whenPlayPressed_expectPlaysMusic() {
        // mocks
        env.inject()

        // sut
        XCTAssertTrue(controlsViewController.playButton.tap())

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenPausePressed_expectPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue(controlsViewController.playButton.tap())

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_controls_whenStopPressed_expectStopsMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue(controlsViewController.stopButton.tap())

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.stop4.name) ?? false)
    }

    func test_controls_whenShufflePressed_expectShufflesMusicAndPlays() {
        // mocks
        let library = (0..<100).map { Track(mediaItem: MockMediaItem(id: $0)) }
        env.setSavedTracks(library.map { MockMediaItem(track: $0) }, currentTrack: MockMediaItem(track: library[1]))
        env.inject()

        // sut
        XCTAssertEqual(env.trackManager.library, library)
        XCTAssertTrue(controlsViewController.shuffleButton.tap())

        // test
        XCTAssertNotEqual(env.trackManager.library, library)
        XCTAssertEqual(env.trackManager.library.count, library.count)
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenPrevPressed_expectPlaysPreviousTrack() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        XCTAssertTrue(controlsViewController.prevButton.tap())

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 0)
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenNextPressed_expectPlaysNextTrack() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        XCTAssertTrue(controlsViewController.nextButton.tap())

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 2)
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenScrubbingMoved_expectChangesPlayLocation() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setPlaying()

        // sut
        let touches = Set<UITouch>(arrayLiteral: MockTouch(x: env.scrubberViewController.viewWidth / 2))
        scrubberViewController.touchesBegan(touches, with: nil)
        scrubberViewController.touchesMoved(touches, with: nil)
        scrubberViewController.touchesEnded(touches, with: nil)

        // test
        XCTAssertEqual(playerFactory.audioPlayer?.currentTime ?? 0, MockMediaItem.playbackDuration / 2)
    }

    func test_controls_whenRepeatAllPressed_expectChangesRepeatState() {
        // mocks
        env.inject()
        env.setRepeatState(.all)

        // sut
        XCTAssertTrue(controlsViewController.repeatButton.tap())

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .none)
    }

    func test_controls_whenRepeatNonePressed_expectChangesRepeatState() {
        // mocks
        env.inject()
        env.setRepeatState(.none)

        // sut
        XCTAssertTrue(controlsViewController.repeatButton.tap())

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .one)
    }

    func test_controls_whenRepeatOnePressed_expectChangesRepeatState() {
        // mocks
        env.inject()
        env.setRepeatState(.one)

        // sut
        XCTAssertTrue( controlsViewController.repeatButton.tap())

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
        env.musicService.setDelegate(delegate: Delegate()) // detach delegate

        // sut
        env.setPlaying()
        NotificationCenter.default.post(name: UIApplication.didBecomeActiveNotification, object: nil)

        // test
        waitSync()
        XCTAssertEqual(controlsViewController.playButton.backgroundImage(for: .normal), Asset.pauseButton.image)
    }
}
