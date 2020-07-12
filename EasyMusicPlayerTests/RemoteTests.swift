@testable import EasyMusic
import MediaPlayer
import TestExtensions
import XCTest

final class RemoteTests: XCTestCase {
    private var controlsViewController: ControlsViewController!
    private var remote: Remoting!
    private var playerFactory: DummyAudioPlayerFactory!
    private var env: AppTestEnvironment!

    override func setUp() {
        super.setUp()
        controlsViewController = .fromStoryboard()
        remote = Remote()
        playerFactory = DummyAudioPlayerFactory()
        env = AppTestEnvironment(remote: remote, controlsViewController: controlsViewController,
                                 playerFactory: playerFactory)
    }

    override func tearDown() {
        remote = nil
        env = nil
        super.tearDown()
    }

    func test_remoteControls_whenPlayPressed_expectPlaysMusic() {
        // mocks
        env.inject()

        // sut
        remote.play?()

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_remoteControls_whenPausePressed_expectPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        remote.pause?()

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_remoteControls_whenTogglePlayPausePressed_expectPlaysMusic() {
        // mocks
        env.inject()

        // sut
        remote.togglePlayPause?()

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_remoteControls_whenTogglePlayPausePressed_expectPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        remote.togglePlayPause?()

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_remoteControls_whenStopPressed_expectStopsMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        remote.stop?()

        // test
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.stop4.name) ?? false)
    }

    func test_remoteControls_whenPrevPressed_expectPlaysPreviousTrack() {
        // mocks
        env.setSavedTracks(library, currentTrack: library[1])
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        remote.prev?()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 0)
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_remoteControls_whenNextPressed_expectPlaysNextTrack() {
        // mocks
        env.setSavedTracks(library, currentTrack: library[1])
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        remote.next?()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 2)
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_remoteControls_whenScrubbingMoved_expectChangesPlayLocation() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        let event = MockChangePlaybackPositionCommandEvent()
        let time = DummyAsset.normal.playbackDuration / 2
        event._positionTime = time
        remote.changePlayback?(event)

        // test
        XCTAssertEqual(playerFactory.audioPlayer?.currentTime ?? 0, time)
    }

    func test_remoteControls_whenPreviousSeeked_expectChangesPlayLocationInTrack() {
        // mocks
        playerFactory.currentTime = 4
        env.seeker = Seeker(seekInterval: 1)
        env.inject()
        env.setPlaying()

        // sut
        let event = MockSeekCommandEvent()
        event._type = .beginSeeking
        remote.seekBackward?(event)

        // test (expect starts)
        waitSync(for: 3.0)
        XCTAssertEqual(playerFactory.audioPlayer?.currentTime ?? 0, 1)

        // sut
        event._type = .endSeeking
        remote.seekBackward?(event)

        // test (expect stops)
        waitSync(for: 3.0)
        XCTAssertEqual(playerFactory.audioPlayer?.currentTime ?? 0, 1)
    }

    func test_remoteControls_whenNextSeeked_expectChangesPlayLocationInTrack() {
        // mocks
        playerFactory.currentTime = 4
        env.seeker = Seeker(seekInterval: 1)
        env.inject()
        env.setPlaying()

        // sut
        let event = MockSeekCommandEvent()
        event._type = .beginSeeking
        remote.seekForward?(event)

        // test (expect starts)
        waitSync(for: 3.0)
        XCTAssertEqual(playerFactory.audioPlayer?.currentTime ?? 0, 7)

        // sut
        event._type = .endSeeking
        remote.seekBackward?(event)

        // test (expect stops)
        waitSync(for: 3.0)
        XCTAssertEqual(playerFactory.audioPlayer?.currentTime ?? 0, 7)
    }

    func test_remoteControls_whenRepeatPressed_expectRepeatButtonChanged() {
        // mocks
        env.seeker = Seeker(seekInterval: 1)
        env.inject()
        env.setPlaying()

        // sut
        let event = MockChangeRepeatModeCommandEvent()
        event._repeatType = .off
        remote.repeatMode?(event)

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatButton.image)
    }

    func test_remoteControls_whenRepeatOnePressed_expectRepeatButtonChanged() {
        // mocks
        env.seeker = Seeker(seekInterval: 1)
        env.inject()
        env.setPlaying()

        // sut
        let event = MockChangeRepeatModeCommandEvent()
        event._repeatType = .one
        remote.repeatMode?(event)

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatOneButton.image)
    }

    func test_remoteControls_whenRepeatAllPressed_expectRepeatButtonChanged() {
        // mocks
        env.seeker = Seeker(seekInterval: 1)
        env.inject()
        env.setPlaying()

        // sut
        let event = MockChangeRepeatModeCommandEvent()
        event._repeatType = .all
        remote.repeatMode?(event)

        // test
        XCTAssertEqual(controlsViewController.repeatButton.backgroundImage(for: .normal), Asset.repeatAllButton.image)
    }
}
