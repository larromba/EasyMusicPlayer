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

    func testPressingPlayPlaysMusic() {
        // mocks
        env.inject()

        // sut
        XCTAssertTrue(controlsViewController.playButton.tap())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testPressingPausePausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue(controlsViewController.playButton.tap())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func testPressingStopStopsMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue(controlsViewController.stopButton.tap())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.stop4.name) ?? false)
    }

    func testPressingShuffleCreatesShufflesAndPlaysTracks() {
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

    func testPressingPrevPlaysPreviousTrack() {
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

    func testPressingNextPlaysNextTrack() {
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

    func testScrubbingChangesPlayLocationInTrack() {
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

    func testPressingRepeatButtonAllChangesRepeatStateToNone() {
        // mocks
        env.inject()
        env.setRepeatState(.all)

        // sut
        XCTAssertTrue(controlsViewController.repeatButton.tap())

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .none)
    }

    func testPressingRepeatButtonNoneChangesRepeatStateToOne() {
        // mocks
        env.inject()
        env.setRepeatState(.none)

        // sut
        XCTAssertTrue(controlsViewController.repeatButton.tap())

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .one)
    }

    func testPressingRepeatButtonOneChangesRepeatStateToAll() {
        // mocks
        env.inject()
        env.setRepeatState(.one)

        // sut
        XCTAssertTrue( controlsViewController.repeatButton.tap())

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .all)
    }
}
