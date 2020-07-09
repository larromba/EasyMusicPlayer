@testable import EasyMusic
import MediaPlayer
import XCTest

final class ControlTests: XCTestCase {
    private var controlsViewController: ControlsViewController!
    private var env: AppTestEnvironment!

    override func setUp() {
        super.setUp()
        controlsViewController = .fromStoryboard()
        env = AppTestEnvironment(controlsViewController: controlsViewController)
    }

    override func tearDown() {
        controlsViewController = nil
        env = nil
        super.tearDown()
    }

    func test_controls_whenPlayPressed_expectPlaysMusic() {
        // mocks
        env.inject()

        // sut
        XCTAssertTrue(controlsViewController.playButton.tap())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenPausePressed_expectPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue(controlsViewController.playButton.tap())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_controls_whenStopPressed_expectStopsMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue(controlsViewController.stopButton.tap())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.stop4.name) ?? false)
    }

    func test_controls_whenShufflePressed_expectShufflesMusicAndPlays() {
        // mocks
        let library = (0..<100).map { MockMediaItem(id: $0) }
        env.setSavedTracks(library, currentTrack: library[1])
        env.inject()

        // sut
        XCTAssertEqual(env.trackManager.tracks, library)
        XCTAssertTrue(controlsViewController.shuffleButton.tap())

        // test
        XCTAssertNotEqual(env.trackManager.tracks, library)
        XCTAssertEqual(env.trackManager.tracks.count, library.count)
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
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
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
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
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_controls_whenScrubbingMoved_expectChangesPlayLocation() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setPlaying()

        // sut
        let touches = Set<UITouch>(arrayLiteral: MockTouch(x: env.scrubberViewController.view.bounds.width / 2))
        scrubberViewController.touchesBegan(touches, with: nil)
        scrubberViewController.touchesMoved(touches, with: nil)
        scrubberViewController.touchesEnded(touches, with: nil)

        // test
        XCTAssertEqual(env.playerFactory.audioPlayer?.currentTime ?? 0, MockMediaItem.playbackDuration / 2)
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
}
