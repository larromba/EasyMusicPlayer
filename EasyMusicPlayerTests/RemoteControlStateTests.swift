@testable import EasyMusic
import MediaPlayer
import XCTest

final class RemoteControlStateTests: XCTestCase {
    private var remote: RemoteControlling!
    private var env: PlayerEnvironment!

    override func setUp() {
        super.setUp()
        remote = MockRemoteCommandCenter()
        env = PlayerEnvironment(remote: remote)
    }

    override func tearDown() {
        remote = nil
        env = nil
        super.tearDown()
    }

    // MARK: - repeat one

    func testPlayStateRepeatOneStart() {
        // mocks
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertFalse(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatOneMid() {
        // mocks
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatOneEnd() {
        // mocks
        let helper = PlayerEnvironmentHelper(currentTrackID: 2)
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertFalse(remote.nextTrackCommand.isEnabled)
    }

    // MARK: - repeat none

    func testPlayStateRepeatNoneStart() {
        // mocks
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertFalse(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatNoneMid() {
        // mocks
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatNoneEnd() {
        // mocks
        let helper = PlayerEnvironmentHelper(currentTrackID: 2)
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertFalse(remote.nextTrackCommand.isEnabled)
    }

    // MARK: - repeat all

    func testPlayStateRepeatAllStart() {
        // mocks
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatAllMid() {
        // mocks
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    func testPlayStateRepeatAllEnd() {
        // mocks
        let helper = PlayerEnvironmentHelper(currentTrackID: 2)
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(remote.previousTrackCommand.isEnabled)
        XCTAssertTrue(remote.nextTrackCommand.isEnabled)
    }

    // MARK: - other

    func testPlayState() {
        // mocks
        env.inject()
        env.setPlaying()

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
        env.inject()
        env.setPaused()

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
        env.inject()
        env.setStopped()

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
        env.inject()
        env.playerFactory.didPlay = false
        env.setPlaying()

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
        let remoteInfo = MockNowPlayingInfoCenter()
        env.remoteInfo = remoteInfo
        let image = UIImage()
        let item = MockMediaItem(artist: "arkist", title: "fill your coffee", image: image)
        let helper = PlayerEnvironmentHelper(tracks: [item], currentTrackID: 0)
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setPlaying()

        // test
        let info = remoteInfo.nowPlayingInfo
        XCTAssertEqual(info?.count, 6)
        XCTAssertEqual(info?[MPMediaItemPropertyArtist] as? String, "arkist")
        XCTAssertEqual(info?[MPMediaItemPropertyTitle] as? String, "fill your coffee")
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval, 0.0)
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyMediaType] as? NSNumber, 1)
        let artwork = remoteInfo.nowPlayingInfo?[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork
        XCTAssertEqual(artwork?.image(at: image.size), image)
        XCTAssertEqual(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval, 210.0)
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval, 0.0)
        var mediaType: MPNowPlayingInfoMediaType?
        if let rawValue = info?[MPNowPlayingInfoPropertyMediaType] as? UInt {
            mediaType = MPNowPlayingInfoMediaType(rawValue: rawValue)
        }
        XCTAssertEqual(mediaType, .audio)
    }

    func testScrubbingChangesRemoteInfo() {
        // mocks
        let remoteInfo = MockNowPlayingInfoCenter()
        env.remoteInfo = remoteInfo
        let scrubberViewController = ScrubberViewController.fromStoryboard
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.scrubberViewController = scrubberViewController
        env.inject()
        env.setPlaying()

        // sut
        let touches = Set<UITouch>(arrayLiteral: MockTouch(x: env.scrubberViewController.view.bounds.width / 2))
        scrubberViewController.touchesBegan(touches, with: nil)
        scrubberViewController.touchesMoved(touches, with: nil)
        scrubberViewController.touchesEnded(touches, with: nil)

        // test
        let info = remoteInfo.nowPlayingInfo
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval,
                       MockMediaItem.playbackDuration / 2)
    }
}
