@testable import EasyMusic
import MediaPlayer
import XCTest

final class ControlStateTests: XCTestCase {
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

    // MARK: - repeat one

    func test_repeatOne_whenPressed_expectIcon() {
        // mocks
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatOneButton.image)
    }

    func test_repeatOne_whenPressedOnFirstTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[0])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertFalse(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func test_repeatOne_whenPressedOnMidTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func test_repeatOne_whenPressedOnEndTrack_expectState() {
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

    func test_repeatNone_whenPressed_expectIcon() {
        // mocks
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatButton.image)
    }

    func test_repeatNone_whenPressedOnFirstTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[0])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertFalse(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func test_repeatNone_whenPressedOnMidTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func test_repeatNone_whenPressedOnEndTrack_expectState() {
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

    func test_repeatAll_whenPressed_expectIcon() {
        // mocks
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatAllButton.image)
    }

    func test_repeatAll_whenPressedOnFirstTrack_expectState() {
        // mocks
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func test_repeatAll_whenPressedOnMidTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(controlsViewController.prevButton.isEnabled)
        XCTAssertTrue(controlsViewController.nextButton.isEnabled)
    }

    func test_repeatAll_whenPressedOnEndTrack_expectState() {
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

    func test_controls_whenPlaying_expectState() {
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

    func test_controls_whenPaused_expectState() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        playerFactory.isPlaying = false
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

    func test_controls_whenStopped_expectState() {
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

    func test_controls_whenErrorPlaying_expectState() {
        // mocks
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        playerFactory.didPlay = false
        env.inject()
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

    func test_controls_whenTrackLoaded_expectInfoDisplayed() {
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
