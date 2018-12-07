@testable import EasyMusic
import MediaPlayer
import XCTest

final class RemoteControlStateTests: XCTestCase {
    private var remote: RemoteControlling!

    override func setUp() {
        super.setUp()
        remote = MockRemoteCommandCenter()
    }

    override func tearDown() {
        remote = nil
        super.tearDown()
    }

    // MARK: - repeat one

    func testPlayStateRepeatOneStart() {
        // mocks
        let env = PlayerEnvironment(repeatState: .one, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertFalse(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatOneMid() {
        // mocks
        let env = PlayerEnvironment(repeatState: .one, trackID: 1, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatOneEnd() {
        // mocks
        let env = PlayerEnvironment(repeatState: .one, trackID: 2, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertFalse(remote.nextTrackCommand.isEnabled)
    }

    // MARK: - repeat none

    func testPlayStateRepeatNoneStart() {
        // mocks
        let env = PlayerEnvironment(repeatState: .none, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertFalse(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatNoneMid() {
        // mocks
        let env = PlayerEnvironment(repeatState: .one, trackID: 1, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatNoneEnd() {
        // mocks
        let env = PlayerEnvironment(repeatState: .one, trackID: 2, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertFalse(remote.nextTrackCommand.isEnabled)
    }

    // MARK: - repeat all

    func testPlayStateRepeatAllStart() {
        // mocks
        let env = PlayerEnvironment(repeatState: .all, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatAllMid() {
        // mocks
        let env = PlayerEnvironment(repeatState: .all, trackID: 1, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatAllEnd() {
        // mocks
        let env = PlayerEnvironment(repeatState: .all, trackID: 2, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    // MARK: - other

    func testPlayState() {
        // mocks
        let env = PlayerEnvironment(remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertFalse(remote.playCommand.isEnabled)
        XCTAssertTrue(remote.pauseCommand.isEnabled)
        XCTAssertTrue(remote.stopCommand.isEnabled)
        XCTAssertTrue(remote.togglePlayPauseCommand.isEnabled)
        XCTAssertTrue(remote.changePlaybackPositionCommand.isEnabled)
        XCTAssertTrue(remote.seekForwardCommand.isEnabled)
        XCTAssertTrue(remote.seekBackwardCommand.isEnabled)
    }

    func testPauseState() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, remote: remote)
        env.inject()

        // sut
        env.musicService.play()
        env.musicService.pause()

        // test
        XCTAssertTrue(remote.playCommand.isEnabled)
        XCTAssertFalse(remote.pauseCommand.isEnabled)
        XCTAssertTrue(remote.stopCommand.isEnabled)
        XCTAssertTrue(remote.togglePlayPauseCommand.isEnabled)
        XCTAssertFalse(remote.changePlaybackPositionCommand.isEnabled)
        XCTAssertFalse(remote.seekForwardCommand.isEnabled)
        XCTAssertFalse(remote.seekBackwardCommand.isEnabled)
        XCTAssertFalse(remote.previousTrackCommand.isEnabled)
        XCTAssertFalse(remote.nextTrackCommand.isEnabled)
    }

    func testStopState() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, remote: remote)
        env.inject()

        // sut
        env.musicService.play()
        env.musicService.stop()

        // test
        XCTAssertTrue(remote.playCommand.isEnabled)
        XCTAssertFalse(remote.pauseCommand.isEnabled)
        XCTAssertFalse(remote.stopCommand.isEnabled)
        XCTAssertTrue(remote.togglePlayPauseCommand.isEnabled)
        XCTAssertFalse(remote.changePlaybackPositionCommand.isEnabled)
        XCTAssertFalse(remote.seekForwardCommand.isEnabled)
        XCTAssertFalse(remote.seekBackwardCommand.isEnabled)
        XCTAssertFalse(remote.previousTrackCommand.isEnabled)
        XCTAssertFalse(remote.nextTrackCommand.isEnabled)
    }

    func testErrorState() {
        // mocks
        let env = PlayerEnvironment(didPlay: false, remote: remote)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.playCommand.isEnabled)
        XCTAssertFalse(remote.pauseCommand.isEnabled)
        XCTAssertFalse(remote.stopCommand.isEnabled)
        XCTAssertTrue(remote.togglePlayPauseCommand.isEnabled)
        XCTAssertFalse(remote.changePlaybackPositionCommand.isEnabled)
        XCTAssertFalse(remote.seekForwardCommand.isEnabled)
        XCTAssertFalse(remote.seekBackwardCommand.isEnabled)
        XCTAssertFalse(remote.previousTrackCommand.isEnabled)
        XCTAssertFalse(remote.nextTrackCommand.isEnabled)
    }

    func testTrackRendersInfo() {
        // mocks
        let image = UIImage()
        let item = MockMediaItem(artist: "arkist", title: "fill your coffee", image: image)
        let remoteInfo = MockNowPlayingInfoCenter()
        let env = PlayerEnvironment(mediaItems: [item], remote: remote, remoteInfo: remoteInfo)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertEqual(remoteInfo.nowPlayingInfo?.count, 6)
        XCTAssertEqual(remoteInfo.nowPlayingInfo?["artist"] as? String, "arkist")
        XCTAssertEqual(remoteInfo.nowPlayingInfo?["title"] as? String, "fill your coffee")
        XCTAssertEqual(remoteInfo.nowPlayingInfo?["MPNowPlayingInfoPropertyElapsedPlaybackTime"] as? TimeInterval, 0.0)
        XCTAssertEqual(remoteInfo.nowPlayingInfo?["MPNowPlayingInfoPropertyMediaType"] as? NSNumber, 1)
        let artwork = remoteInfo.nowPlayingInfo?["artwork"] as? MPMediaItemArtwork
        XCTAssertEqual(artwork?.image(at: image.size), image)
        XCTAssertEqual(remoteInfo.nowPlayingInfo?["playbackDuration"] as? TimeInterval, 210.0)
    }
}
