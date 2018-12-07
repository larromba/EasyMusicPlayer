@testable import EasyMusic
import MediaPlayer
import TestExtensions
import XCTest

final class RemoteControlTests: XCTestCase {
    private var remote: RemoteControlling!

    override func setUp() {
        super.setUp()
        remote = MockRemoteCommandCenter()
    }

    override func tearDown() {
        remote = nil
        super.tearDown()
    }

    func testPressingPlayPlaysMusic() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, remote: remote)
        env.inject()

        // sut
        (remote.playCommand as! MockRemoteCommand).fire()

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testPressingPausePausesMusic() {
        // mocks
        let env = PlayerEnvironment(remote: remote)
        env.inject()

        // sut
        (remote.playCommand as! MockRemoteCommand).fire()
        (remote.pauseCommand as! MockRemoteCommand).fire()

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func testTogglePlayPausePlaysMusic() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, remote: remote)
        env.inject()

        // sut
        (remote.togglePlayPauseCommand as! MockRemoteCommand).fire()

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testTogglePlayPausePausesMusic() {
        // mocks
        let env = PlayerEnvironment(remote: remote)
        env.inject()

        // sut
        (remote.togglePlayPauseCommand as! MockRemoteCommand).fire()
        (remote.togglePlayPauseCommand as! MockRemoteCommand).fire()

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func testPressingStopStopsMusic() {
        // mocks
        let env = PlayerEnvironment(remote: remote)
        env.inject()

        // sut
        (remote.playCommand as! MockRemoteCommand).fire()
        (remote.stopCommand as! MockRemoteCommand).fire()

        // test
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.stop4.name) ?? false)
    }

    func testPressingPrevPlaysPreviousTrack() {
        // mocks
        let env = PlayerEnvironment(trackID: 1, remote: remote)
        env.inject()

        // sut
        (remote.playCommand as! MockRemoteCommand).fire()
        (remote.previousTrackCommand as! MockRemoteCommand).fire()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 0)
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testPressingNextPlaysNextTrack() {
        // mocks
        let env = PlayerEnvironment(trackID: 1, remote: remote)
        env.inject()

        // sut
        (remote.playCommand as! MockRemoteCommand).fire()
        (remote.nextTrackCommand as! MockRemoteCommand).fire()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 2)
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testScrobblingChangesPlayLocationInTrack() {
        // mocks
        let env = PlayerEnvironment(remote: remote)
        env.inject()

        // sut
        (remote.playCommand as! MockRemoteCommand).fire()
        (remote.changePlaybackPositionCommand as! MockChangePlaybackPositionCommand).fire()

        // test
        XCTAssertEqual(env.playerFactory.audioPlayer?.currentTime ?? 0, MockMediaItem.playbackDuration / 2)
    }

    func testSeeksPreviousChangesPlayLocationInTrack() {
        // mocks
        let env = PlayerEnvironment(currentTime: 4, remote: remote)
        env.inject()

        // sut
        (remote.playCommand as! MockRemoteCommand).fire()
        (remote.seekBackwardCommand as! MockSeekRemoteCommand).fire()

        // test
        wait(for: 3.0) {
            XCTAssertEqual(env.playerFactory.audioPlayer?.currentTime ?? 0, 2)
        }
    }

    func testSeekNextChangesPlayLocationInTrack() {
        // mocks
        let env = PlayerEnvironment(remote: remote)
        env.inject()

        // sut
        (remote.playCommand as! MockRemoteCommand).fire()
        (remote.seekForwardCommand as! MockSeekRemoteCommand).fire()

        // test
        wait(for: 3.0) {
            XCTAssertEqual(env.playerFactory.audioPlayer?.currentTime ?? 0, 2)
        }
    }
}
