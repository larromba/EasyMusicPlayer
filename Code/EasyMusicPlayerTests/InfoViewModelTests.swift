@testable import EasyMusicPlayer
import MediaPlayer
import XCTest

@MainActor
final class InfoViewModelTests: XCTestCase {
    private var musicPlayer: MusicPlayableMock!
    private var remote: NowPlayingInfoCenterMock!
    private var sut: InfoViewModel!

    override func setUpWithError() throws {
        setup()
    }

    override func tearDownWithError() throws {
        musicPlayer = nil
        remote = nil
        sut = nil
    }

    // MARK: - state

    func test_state_whenPlayReceived_expectItemUpdate() {
        let item = MediaItemMock()
        setup(musicPlayer: MusicPlayableMock(info: .mock(track: item)))

        musicPlayer.stateSubject.send(.play)

        XCTAssertEqual(sut.track, item)
    }

    func test_state_whenPlayReceived_expectTimeUpdate() {
        setup(musicPlayer: MusicPlayableMock(info: .mock(time: 60)))

        musicPlayer.stateSubject.send(.play)

        XCTAssertEqual(sut.time, "00:01:00")
    }

    func test_state_whenPlayReceived_expectPositionUpdate() {
        setup(musicPlayer: MusicPlayableMock(info: .mock(index: 0, tracks: [.mock(), .mock()])))

        musicPlayer.stateSubject.send(.play)

        XCTAssertEqual(sut.position, "1 of 2")
    }

    func test_state_whenPlayReceived_expectRemoteUpdate() {
        let item = MediaItemMock(artist: "artist", title: "title", artwork: .mock, playbackDuration: 100)
        setup(musicPlayer: MusicPlayableMock(info: .mock(track: item, time: 10)))

        musicPlayer.stateSubject.send(.play)

        let info = remote.nowPlayingInfo
        XCTAssertEqual(info?[MPMediaItemPropertyArtist] as? String, "artist")
        XCTAssertEqual(info?[MPMediaItemPropertyTitle] as? String, "title")
        XCTAssertNotNil(info?[MPMediaItemPropertyArtwork])
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyMediaType] as? UInt, MPNowPlayingInfoMediaType.audio.rawValue)
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval, 10)
        XCTAssertEqual(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval, 100)
    }

    func test_state_whenResetReceived_expectItemUpdate() {
        musicPlayer.stateSubject.send(.reset)

        XCTAssertEqual(sut.track, nil)
    }

    func test_state_whenResetReceived_expectTimeUpdate() {
        musicPlayer.stateSubject.send(.reset)

        XCTAssertEqual(sut.time, "")
    }

    func test_state_whenResetReceived_expectPositionUpdate() {
        musicPlayer.stateSubject.send(.reset)

        XCTAssertEqual(sut.position, "")
    }

    func test_state_whenResetReceived_expectRemoteUpdate() {
        remote.nowPlayingInfo = [MPNowPlayingInfoPropertyElapsedPlaybackTime: 60]

        musicPlayer.stateSubject.send(.reset)

        let info = remote.nowPlayingInfo
        XCTAssertTrue(info?.keys.isEmpty ?? false)
    }

    func test_state_whenStopReceived_expectTimeUpdate() {
        musicPlayer.stateSubject.send(.stop)

        XCTAssertEqual(sut.time, "00:00:00")
    }

    func test_state_whenStopReceived_expectRemoteUpdate() {
        remote.nowPlayingInfo = [:]
        sut.track = MediaItemMock()

        musicPlayer.stateSubject.send(.stop)

        let info = remote.nowPlayingInfo
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval, 0.0)
    }

    func test_state_whenClockReceived_expecTimeUpdate() {
        musicPlayer.stateSubject.send(.clock(60))

        XCTAssertEqual(sut.time, "00:01:00")
    }

    func test_state_whenClockReceived_expectRemoteUpdate() {
        remote.nowPlayingInfo = [:]
        sut.track = MediaItemMock(playbackDuration: 100)

        musicPlayer.stateSubject.send(.clock(60))

        let info = remote.nowPlayingInfo
        XCTAssertEqual(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval, 60.0)
        XCTAssertEqual(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval, 100)
    }

    func test_state_whenClockReceived_expectCorrectTimeFormats() {
        musicPlayer.stateSubject.send(.clock(60))
        XCTAssertEqual(sut.time, "00:01:00")

        musicPlayer.stateSubject.send(.clock(60 * 10))
        XCTAssertEqual(sut.time, "00:10:00")

        musicPlayer.stateSubject.send(.clock(60 * 60 * 1))
        XCTAssertEqual(sut.time, "01:00:00")
    }

    private func setup(
        musicPlayer: MusicPlayableMock = MusicPlayableMock(),
        remote: NowPlayingInfoCenterMock =  NowPlayingInfoCenterMock()
    ) {
        self.musicPlayer = musicPlayer
        self.remote = remote
        sut = InfoViewModel(musicPlayer: musicPlayer, remote: remote)
    }
}
