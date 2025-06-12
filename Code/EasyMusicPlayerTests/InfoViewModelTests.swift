@testable import EasyMusicPlayer
import MediaPlayer
import Testing

@MainActor
struct InfoViewModelTests {
    // MARK: - state

    @Test
    func state_whenPlayReceived_expectItemUpdate() {
        let item = MediaItemMock()
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: item)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.sut.track == item)
    }

    @Test
    func state_whenPlayReceived_expectTimeUpdate() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(time: 60)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.sut.time == "00:01:00")
    }

    @Test
    func state_whenPlayReceived_expectPositionUpdate() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(index: 0, tracks: [.mock(), .mock()])))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.sut.position == "1 of 2")
    }

    @Test
    func state_whenPlayReceived_expectRemoteUpdate() {
        let item = MediaItemMock(artist: "artist", title: "title", artwork: .mock, playbackDuration: 100)
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: item, time: 10)))

        env.musicPlayer.stateSubject.send(.play)

        let info = env.remote.nowPlayingInfo
        #expect(info?[MPMediaItemPropertyArtist] as? String == "artist")
        #expect(info?[MPMediaItemPropertyTitle] as? String == "title")
        #expect(info?[MPMediaItemPropertyArtwork] != nil)
        #expect(info?[MPNowPlayingInfoPropertyMediaType] as? UInt == MPNowPlayingInfoMediaType.audio.rawValue)
        #expect(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval == 10)
        #expect(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval == 100)
    }

    @Test
    func state_whenResetReceived_expectItemUpdate() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.reset)

        #expect(env.sut.track == nil)
    }

    @Test
    func state_whenResetReceived_expectTimeUpdate() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.reset)

        #expect(env.sut.time == "")
    }

    @Test
    func state_whenResetReceived_expectPositionUpdate() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.reset)

        #expect(env.sut.position == "")
    }

    @Test
    func state_whenResetReceived_expectRemoteUpdate() {
        let env = setup()
        env.remote.nowPlayingInfo = [MPNowPlayingInfoPropertyElapsedPlaybackTime: 60]

        env.musicPlayer.stateSubject.send(.reset)

        let info = env.remote.nowPlayingInfo
        #expect(info?.keys.isEmpty ?? false)
    }

    @Test
    func state_whenStopReceived_expectTimeUpdate() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.stop)

        #expect(env.sut.time == "00:00:00")
    }

    @Test
    func state_whenStopReceived_expectRemoteUpdate() {
        let env = setup()
        env.remote.nowPlayingInfo = [:]
        env.sut.track = MediaItemMock()

        env.musicPlayer.stateSubject.send(.stop)

        let info = env.remote.nowPlayingInfo
        #expect(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval == 0.0)
    }

    @Test
    func state_whenClockReceived_expecTimeUpdate() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.clock(60))

        #expect(env.sut.time == "00:01:00")
    }

    @Test
    func state_whenClockReceived_expectRemoteUpdate() {
        let env = setup()
        env.remote.nowPlayingInfo = [:]
        env.sut.track = MediaItemMock(playbackDuration: 100)

        env.musicPlayer.stateSubject.send(.clock(60))

        let info = env.remote.nowPlayingInfo
        #expect(info?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval == 60.0)
        #expect(info?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval == 100)
    }

    @Test
    func state_whenClockIsMinute_expectMinuteFormat() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.clock(60))

        #expect(env.sut.time == "00:01:00")
    }

    @Test
    func state_whenClockIsTenMinutes_expectTenMinuteFormat() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.clock(60 * 10))

        #expect(env.sut.time == "00:10:00")
    }

    @Test
    func state_whenClockIsHour_expectHourFormat() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.clock(60 * 60 * 1))

        #expect(env.sut.time == "01:00:00")
    }

    private func setup(
        musicPlayer: MusicPlayableMock = MusicPlayableMock(),
        remote: NowPlayingInfoCenterMock =  NowPlayingInfoCenterMock()
    ) -> Environmemnt {
        Environmemnt(
            musicPlayer: musicPlayer,
            remote: remote,
            sut: InfoViewModel(musicPlayer: musicPlayer, remote: remote)
        )
    }
}

private extension InfoViewModelTests {
    struct Environmemnt {
        let musicPlayer: MusicPlayableMock
        let remote: NowPlayingInfoCenterMock
        let sut: InfoViewModel
    }
}
