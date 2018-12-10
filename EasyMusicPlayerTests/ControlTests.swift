@testable import EasyMusic
import MediaPlayer
import XCTest

final class ControlTests: XCTestCase {
    func testPressingPlayPlaysMusic() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false)
        env.inject()

        // sut
        env.controlsViewController.playButton.tap()

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testPressingPausePausesMusic() {
        // mocks
        let env = PlayerEnvironment()
        env.inject()

        // sut
        env.controlsViewController.playButton.tap()
        env.controlsViewController.playButton.tap()

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func testPressingStopStopsMusic() {
        // mocks
        let env = PlayerEnvironment()
        env.inject()

        // sut
        env.controlsViewController.playButton.tap()
        env.controlsViewController.stopButton.tap()

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.stop4.name) ?? false)
    }

    func testPressingShuffleCreatesAndPlaysTracks() {
        // mocks
        let env = PlayerEnvironment()
        env.inject()

        // sut
        env.controlsViewController.shuffleButton.tap()

        // test
        XCTAssertTrue(env.playlist.invocations.isInvoked(MockPlaylist.create1.name))
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testPressingPrevPlaysPreviousTrack() {
        // mocks
        let env = PlayerEnvironment(trackID: 1)
        env.inject()

        // sut
        env.controlsViewController.playButton.tap()
        env.controlsViewController.prevButton.tap()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 0)
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testPressingNextPlaysNextTrack() {
        // mocks
        let env = PlayerEnvironment(trackID: 1)
        env.inject()

        // sut
        env.controlsViewController.playButton.tap()
        env.controlsViewController.nextButton.tap()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 2)
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testScrubbingChangesPlayLocationInTrack() {
        // mocks
        let env = PlayerEnvironment()
        env.inject()

        // sut
        env.controlsViewController.playButton.tap()
        let touches = Set<UITouch>(arrayLiteral: MockTouch(x: env.scrubberViewController.view.bounds.width / 2))
        env.scrubberViewController.touchesBegan(touches, with: nil)
        env.scrubberViewController.touchesMoved(touches, with: nil)
        env.scrubberViewController.touchesEnded(touches, with: nil)

        // test
        XCTAssertEqual(env.playerFactory.audioPlayer?.currentTime ?? 0, MockMediaItem.playbackDuration / 2)
    }

    func testPressingRepeatButtonAllChangesRepeatStateToNone() {
        // mocks
        let env = PlayerEnvironment(repeatState: .all)
        env.inject()

        // sut
        env.controlsViewController.repeatButton.tap()

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .none)
    }

    func testPressingRepeatButtonNoneChangesRepeatStateToOne() {
        // mocks
        let env = PlayerEnvironment(repeatState: .none)
        env.inject()

        // sut
        env.controlsViewController.repeatButton.tap()

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .one)
    }

    func testPressingRepeatButtonOneChangesRepeatStateToAll() {
        // mocks
        let env = PlayerEnvironment(repeatState: .one)
        env.inject()

        // sut
        env.controlsViewController.repeatButton.tap()

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .all)
    }
}
