@testable import EasyMusic
import MediaPlayer
import XCTest

final class ControlStateTests: XCTestCase {
    // MARK: - repeat one

    func testRepeatOne() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .one)
        env.inject()

        // sut
        env.musicService.play()
        env.musicService.stop()

        // test
        XCTAssertEqual(env.controlsViewController.repeatButton.backgroundImage(for: .normal),
                       Asset.repeatOneButton.image)
    }

    func testPlayStateRepeatOneStart() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .one)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertFalse(env.controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatOneMid() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .one, trackID: 1)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(env.controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatOneEnd() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .one, trackID: 2)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(env.controlsViewController.prevButton.isEnabled)
        XCTAssertFalse(env.controlsViewController.nextButton.isEnabled)
    }

    // MARK: - repeat none

    func testRepeatNone() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .none)
        env.inject()

        // sut
        env.musicService.play()
        env.musicService.stop()

        // test
        XCTAssertEqual(env.controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatButton.image)
    }

    func testPlayStateRepeatNoneStart() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .none)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertFalse(env.controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatNoneMid() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .one, trackID: 1)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(env.controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatNoneEnd() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .one, trackID: 2)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(env.controlsViewController.prevButton.isEnabled)
        XCTAssertFalse(env.controlsViewController.nextButton.isEnabled)
    }

    // MARK: - repeat all

    func testRepeatAll() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .all)
        env.inject()

        // sut
        env.musicService.play()
        env.musicService.stop()

        // test
        XCTAssertEqual(env.controlsViewController.repeatButton.backgroundImage(for: .normal),
                       Asset.repeatAllButton.image)
    }

    func testPlayStateRepeatAllStart() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .all)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(env.controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatAllMid() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .all, trackID: 1)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(env.controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatAllEnd() {
        // mocks
        let env = MusicControlEnvironment(repeatState: .all, trackID: 2)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(env.controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.nextButton.isEnabled)
    }

    // MARK: - other

    func testPlayState() {
        // mocks
        let env = MusicControlEnvironment()
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertEqual(env.controlsViewController.playButton.backgroundImage(for: .normal), Asset.pauseButton.image)
        XCTAssertTrue(env.controlsViewController.playButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.stopButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.shuffleButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.repeatButton.isEnabled)
        XCTAssertTrue(env.scrubberViewController.view.isUserInteractionEnabled)
    }

    func testPauseState() {
        // mocks
        let env = MusicControlEnvironment()
        env.inject()

        // sut
        env.musicService.play()
        env.musicService.pause()

        // test
        XCTAssertEqual(env.controlsViewController.playButton.backgroundImage(for: .normal), Asset.playButton.image)
        XCTAssertTrue(env.controlsViewController.playButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.stopButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.shuffleButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.repeatButton.isEnabled)
        XCTAssertFalse(env.scrubberViewController.view.isUserInteractionEnabled)
    }

    func testStopState() {
        // mocks
        let env = MusicControlEnvironment()
        env.inject()

        // sut
        env.musicService.play()
        env.musicService.stop()

        // test
        XCTAssertEqual(env.controlsViewController.playButton.backgroundImage(for: .normal), Asset.playButton.image)
        XCTAssertTrue(env.controlsViewController.playButton.isEnabled)
        XCTAssertFalse(env.controlsViewController.stopButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.shuffleButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.repeatButton.isEnabled)
        XCTAssertFalse(env.scrubberViewController.view.isUserInteractionEnabled)
    }

    func testErrorState() {
        // mocks
        let env = MusicControlEnvironment(didPlay: false)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertEqual(env.controlsViewController.playButton.backgroundImage(for: .normal), Asset.playButton.image)
        XCTAssertTrue(env.controlsViewController.playButton.isEnabled)
        XCTAssertFalse(env.controlsViewController.stopButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.shuffleButton.isEnabled)
        XCTAssertTrue(env.controlsViewController.repeatButton.isEnabled)
        XCTAssertFalse(env.scrubberViewController.view.isUserInteractionEnabled)
    }

    func testTrackRendersInfo() {
        XCTFail("todo")
    }
}
