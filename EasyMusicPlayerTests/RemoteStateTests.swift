@testable import EasyMusic
import MediaPlayer
import XCTest

final class RemoteStateTests: XCTestCase {
    private var remoteCommandCenter: MPRemoteCommandCenter!
    private var remote: Remote!
    private var env: AppTestEnvironment!
    private var playerFactory: DummyAudioPlayerFactory!

    override func setUp() {
        super.setUp()
        remoteCommandCenter = MPRemoteCommandCenter.shared()
        playerFactory = DummyAudioPlayerFactory()
        remote = Remote(remote: remoteCommandCenter)
        env = AppTestEnvironment(remote: remote, playerFactory: playerFactory)
    }

    override func tearDown() {
        remoteCommandCenter = nil
        playerFactory = nil
        remote = nil
        env = nil
        super.tearDown()
    }

    // MARK: - repeat one

    func test_repeatOne_whenPressedOnFirstTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[0])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertFalse(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_repeatOne_whenPressedOnMidTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // test
        XCTAssertTrue(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_repeatOne_whenPressedOnEndTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[2])
        env.inject()
        env.setRepeatState(.one)
        env.setPlaying()

        // sut
        env.musicService.play()

        // test
        XCTAssertTrue(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    // MARK: - repeat none

    func test_repeatNone_whenPressedOnFirstTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[0])
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertFalse(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_repeatNone_whenPressedOnMidTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertTrue(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_repeatNone_whenPressedOnEndTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[2])
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // test
        XCTAssertTrue(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    // MARK: - repeat all

    func test_repeatAll_whenPressedOnFirstTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[0])
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_repeatAll_whenPressedOnMidTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_repeatAll_whenPressedOnEndTrack_expectState() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[2])
        env.inject()
        env.setRepeatState(.all)
        env.setPlaying()

        // test
        XCTAssertTrue(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    // MARK: - other

    func test_remoteCommandCenterControls_whenPlaying_expectState() {
        // mocks
        env.inject()
        env.setPlaying()

        // test
        XCTAssertFalse(remoteCommandCenter.playCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.pauseCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.stopCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.togglePlayPauseCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.changePlaybackPositionCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.seekForwardCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.seekBackwardCommand.isEnabled)
    }

    func test_remoteCommandCenterControls_whenPaused_expectState() {
        // mocks
        playerFactory.isPlaying = false
        env.inject()
        env.setPaused()

        // test
        XCTAssertTrue(remoteCommandCenter.playCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.pauseCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.stopCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.togglePlayPauseCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.changePlaybackPositionCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.seekForwardCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.seekBackwardCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_remoteCommandCenterControls_whenStopped_expectState() {
        // mocks
        env.inject()
        env.setStopped()

        // test
        XCTAssertTrue(remoteCommandCenter.playCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.pauseCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.stopCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.togglePlayPauseCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.changePlaybackPositionCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.seekForwardCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.seekBackwardCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_remoteCommandCenterControls_whenErrorPlaying_expectState() {
        // mocks
        playerFactory.didPlay = false
        env.inject()
        env.setPlaying()

        // test
        XCTAssertTrue(remoteCommandCenter.playCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.pauseCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.stopCommand.isEnabled)
        XCTAssertTrue(remoteCommandCenter.togglePlayPauseCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.changePlaybackPositionCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.seekForwardCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.seekBackwardCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.previousTrackCommand.isEnabled)
        XCTAssertFalse(remoteCommandCenter.nextTrackCommand.isEnabled)
    }

    func test_remoteCommandCenterControls_whenTrackLoaded_expectInfoDisplayed() {
        // mocks
        let remoteCommandCenterInfo = MockNowPlayingInfoCenter()
        env.remoteInfo = remoteCommandCenterInfo
        let image = UIImage()
        let item = MockMediaItem(artist: "arkist", title: "fill your coffee", image: image)
        env.setSavedTracks([item], currentTrack: item)
        env.inject()
        env.setPlaying()

        // test
        let info = remoteCommandCenterInfo.nowPlayingInfo
        XCTAssertEqual(info?.count, 6)
        XCTAssertEqual(info?[MPMediaItemPropertyArtist] as? String, "arkist")
        XCTAssertEqual(info?[MPMediaItemPropertyTitle] as? String, "fill your coffee")
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval, 0.0)
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyMediaType] as? NSNumber, 1)
        let artwork = remoteCommandCenterInfo.nowPlayingInfo?[MPMediaItemPropertyArtwork] as? MPMediaItemArtwork
        XCTAssertEqual(artwork?.image(at: image.size), image)
        XCTAssertEqual(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval, 210.0)
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval, 0.0)
        var mediaType: MPNowPlayingInfoMediaType?
        if let rawValue = info?[MPNowPlayingInfoPropertyMediaType] as? UInt {
            mediaType = MPNowPlayingInfoMediaType(rawValue: rawValue)
        }
        XCTAssertEqual(mediaType, .audio)
    }

    func test_remoteCommandCenterControls_whenScrubbingMoved_expectInfoChanged() {
        // mocks
        let remoteCommandCenterInfo = MockNowPlayingInfoCenter()
        env.remoteInfo = remoteCommandCenterInfo
        let scrubberViewController: ScrubberViewController = .fromStoryboard()
        env.scrubberViewController = scrubberViewController
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setPlaying()

        // sut
        let touches = Set<UITouch>(arrayLiteral: MockTouch(x: env.scrubberViewController.viewWidth / 2))
        scrubberViewController.touchesBegan(touches, with: nil)
        scrubberViewController.touchesMoved(touches, with: nil)
        scrubberViewController.touchesEnded(touches, with: nil)

        // test
        let info = remoteCommandCenterInfo.nowPlayingInfo
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval,
                       MockMediaItem.playbackDuration / 2)
    }
}
