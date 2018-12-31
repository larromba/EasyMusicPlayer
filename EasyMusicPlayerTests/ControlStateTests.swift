@testable import EasyMusic
import MediaPlayer
import XCTest

final class ControlStateTests: XCTestCase {
    private var controlsViewController: ControlsViewController!
    private var env: PlayerEnvironment!

    override func setUp() {
        super.setUp()
        controlsViewController = .fromStoryboard()
        env = PlayerEnvironment(controlsViewController: controlsViewController)
    }

    override func tearDown() {
        controlsViewController = nil
        env = nil
        super.tearDown()
    }

    // MARK: - repeat one

    func testRepeatOne() {
        // mocks
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatOneButton.image)
    }

    func testPlayStateRepeatOneStart() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[0])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertFalse(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatOneMid() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatOneEnd() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[2])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertFalse(controlsViewController.nextButton.isEnabled)
    }

    // MARK: - repeat none

    func testRepeatNone() {
        // mocks
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatButton.image)
    }

    func testPlayStateRepeatNoneStart() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[0])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertFalse(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatNoneMid() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatNoneEnd() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[2])
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertFalse(controlsViewController.nextButton.isEnabled)
    }

    // MARK: - repeat all

    func testRepeatAll() {
        // mocks
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatAllButton.image)
    }

    func testPlayStateRepeatAllStart() {
        // mocks
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatAllMid() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func testPlayStateRepeatAllEnd() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[2])
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    // MARK: - other

    func testPlayState() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        env.inject()
        env.setPlaying()

        // test
        XCTAssertEqual(controlsViewController.playButton.backgroundImage(for: .normal), Asset.pauseButton.image)
        XCTAssertTrue(controlsViewController.playButton.isEnabled)
        XCTAssertTrue(controlsViewController.stopButton.isEnabled)
        XCTAssertTrue(controlsViewController.shuffleButton.isEnabled)
        XCTAssertTrue(controlsViewController.repeatButton.isEnabled)
        XCTAssertTrue(scrubberViewController.view.isUserInteractionEnabled)
    }

    func testPauseState() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        env.inject()
        env.setPaused()

        // test
        XCTAssertEqual(controlsViewController.playButton.backgroundImage(for: .normal), Asset.playButton.image)
        XCTAssertTrue(controlsViewController.playButton.isEnabled)
        XCTAssertTrue(controlsViewController.stopButton.isEnabled)
        XCTAssertTrue(controlsViewController.shuffleButton.isEnabled)
        XCTAssertTrue(controlsViewController.repeatButton.isEnabled)
        XCTAssertFalse(scrubberViewController.view.isUserInteractionEnabled)
        XCTAssertFalse(controlsViewController.prevButton.isEnabled)
        XCTAssertFalse(controlsViewController.nextButton.isEnabled)
    }

    func testStopState() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        env.inject()
        env.setStopped()

        // test
        XCTAssertEqual(controlsViewController.playButton.backgroundImage(for: .normal), Asset.playButton.image)
        XCTAssertTrue(controlsViewController.playButton.isEnabled)
        XCTAssertFalse(controlsViewController.stopButton.isEnabled)
        XCTAssertTrue(controlsViewController.shuffleButton.isEnabled)
        XCTAssertTrue(controlsViewController.repeatButton.isEnabled)
        XCTAssertFalse(scrubberViewController.view.isUserInteractionEnabled)
        XCTAssertFalse(controlsViewController.prevButton.isEnabled)
        XCTAssertFalse(controlsViewController.nextButton.isEnabled)
    }

    func testErrorState() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        env.inject()
        env.playerFactory.didPlay = false
        env.setPlaying()

        // test
        XCTAssertEqual(controlsViewController.playButton.backgroundImage(for: .normal), Asset.playButton.image)
        XCTAssertTrue(controlsViewController.playButton.isEnabled)
        XCTAssertFalse(controlsViewController.stopButton.isEnabled)
        XCTAssertTrue(controlsViewController.shuffleButton.isEnabled)
        XCTAssertTrue(controlsViewController.repeatButton.isEnabled)
        XCTAssertFalse(scrubberViewController.view.isUserInteractionEnabled)
        XCTAssertFalse(controlsViewController.prevButton.isEnabled)
        XCTAssertFalse(controlsViewController.nextButton.isEnabled)
    }

    func testTrackRendersInfo() {
        // mocks
        let infoViewController: InfoViewController = .fromStoryboard()
        env.infoViewController = infoViewController
        let image = UIImage()
        let item = MockMediaItem(artist: "arkist", title: "fill your coffee", image: image)
        env.setSavedTracks([item], currentTrack: item)
        env.inject()
        env.setPlaying()

        // test
        XCTAssertEqual(infoViewController.artistLabel.text, "arkist")
        XCTAssertEqual(infoViewController.trackLabel.text, "fill your coffee")
        XCTAssertEqual(infoViewController.trackPositionLabel.text, "1 of 1")
        XCTAssertEqual(infoViewController.timeLabel.text, "00:00:00")
        XCTAssertEqual(infoViewController.artworkImageView.image, image)
    }
}
