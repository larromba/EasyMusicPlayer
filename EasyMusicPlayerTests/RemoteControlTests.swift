@testable import EasyMusic
import MediaPlayer
import TestExtensions
import XCTest

final class RemoteControlTests: XCTestCase {
    private var remote: RemoteControlling!
    private var env: AppTestEnvironment!

    override func setUp() {
        super.setUp()
        remote = MockRemoteCommandCenter()
        env = AppTestEnvironment(remote: remote)
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
        XCTAssertTrue((remote.playCommand as! MockRemoteCommand).fire())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_remoteControls_whenPausePressed_expectPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue((remote.pauseCommand as! MockRemoteCommand).fire())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_remoteControls_whenTogglePlayPausePressed_expectPlaysMusic() {
        // mocks
        env.inject()

        // sut
        XCTAssertTrue((remote.togglePlayPauseCommand as! MockRemoteCommand).fire())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_remoteControls_whenTogglePlayPausePressed_expectPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue((remote.togglePlayPauseCommand as! MockRemoteCommand).fire())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_remoteControls_whenStopPressed_expectStopsMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertTrue((remote.stopCommand as! MockRemoteCommand).fire())

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.stop4.name) ?? false)
    }

    func test_remoteControls_whenPrevPressed_expectPlaysPreviousTrack() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        XCTAssertTrue((remote.previousTrackCommand as! MockRemoteCommand).fire())

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 0)
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_remoteControls_whenNextPressed_expectPlaysNextTrack() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setPlaying()

        // sut
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        XCTAssertTrue((remote.nextTrackCommand as! MockRemoteCommand).fire())

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 2)
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_remoteControls_whenScrubbingMoved_expectChangesPlayLocation() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        (remote.changePlaybackPositionCommand as! MockChangePlaybackPositionCommand).fire()

        // test
        XCTAssertEqual(env.playerFactory.audioPlayer?.currentTime ?? 0, MockMediaItem.playbackDuration / 2)
    }

    func test_remoteControls_whenPreviousSeeked_expectChangesPlayLocationInTrack() {
        // mocks
        env.seeker = Seeker(seekInterval: 1)
        env.inject()
        env.setCurrentTime(4)
        env.setPlaying()

        // sut
        (remote.seekBackwardCommand as! MockSeekRemoteCommand).fire()

        // test
        waitSync(for: 3.0)
        XCTAssertEqual(self.env.playerFactory.audioPlayer?.currentTime ?? 0, 2)
    }

    func test_remoteControls_whenNextSeeked_expectChangesPlayLocationInTrack() {
        // mocks
        env.seeker = Seeker(seekInterval: 1)
        env.inject()
        env.setCurrentTime(4)
        env.setPlaying()

        // sut
        (remote.seekForwardCommand as! MockSeekRemoteCommand).fire()

        // test
        waitSync(for: 3.0)
        XCTAssertEqual(self.env.playerFactory.audioPlayer?.currentTime ?? 0, 6)
    }
}
