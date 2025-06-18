@testable import EasyMusicPlayer
import MediaPlayer
import Testing

@MainActor
struct InfoViewModelTests: Waitable {
    // MARK: - state (play)

    @Test
    func state_whenPlayReceived_expectViewUpdates() {
        let track = MediaItemMock(title: "title")
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: track)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.sut.title == "title")
    }

    @Test
    func state_whenPlayReceived_expectRemoteTitleUpdate() {
        let track = MediaItemMock(title: "title")
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: track)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.remote.nowPlayingInfo?[MPMediaItemPropertyTitle] as? String == "title")
    }

    @Test
    func state_whenPlayReceived_expectArtistUpdate() {
        let track = MediaItemMock(artist: "artist")
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: track)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.sut.artist == "artist")
    }

    @Test
    func state_whenPlayReceived_expectRemoteArtistUpdate() {
        let track = MediaItemMock(artist: "artist")
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: track)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.remote.nowPlayingInfo?[MPMediaItemPropertyArtist] as? String == "artist")
    }

    @Test
    func state_whenPlayReceived_expectArtworkUpdate() async throws {
        let artwork = UIImage()
        let track = MediaItemMock(artwork: .mock(image: artwork))
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: track)))

        env.musicPlayer.stateSubject.send(.play)

        try await waitSync(for: 1.0)
        #expect(env.sut.artwork == artwork)
    }

    @Test
    func state_whenPlayReceived_expectRemoteArtworkUpdate() async throws {
        let track = MediaItemMock(artwork: .mock())
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: track)))

        env.musicPlayer.stateSubject.send(.play)

        try await waitSync()
        #expect(env.remote.nowPlayingInfo?[MPMediaItemPropertyArtwork] != nil)
    }

    @Test
    func state_whenPlayReceived_expectTimeUpdate() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: .mock(), time: 60)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.sut.time == "00:01:00")
    }

    @Test
    func state_whenPlayReceived_expectRemoteTimeUpdate() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: .mock(), time: 10)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.remote.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval == 10)
    }

    @Test
    func state_whenPlayReceived_expectPositionUpdate() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: .mock(), index: 0, tracks: [.mock(), .mock()])))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.sut.position == "1 of 2")
    }

    @Test
    func state_whenPlayReceived_expectRemoteDurationUpdate() {
        let track = MediaItemMock(playbackDuration: 100)
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: track)))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.remote.nowPlayingInfo?[MPMediaItemPropertyPlaybackDuration] as? TimeInterval == 100)
    }

    @Test
    func state_whenPlayReceived_expectRemoteMediaTypeUpdate() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: .mock())))

        env.musicPlayer.stateSubject.send(.play)

        #expect(env.remote.nowPlayingInfo?[MPNowPlayingInfoPropertyMediaType] as? UInt == MPNowPlayingInfoMediaType.audio.rawValue)
    }

    // MARK: - state (reset)

    @Test
    func state_whenResetReceived_expectViewReset() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.reset)

        #expect(env.sut.title == "")
        #expect(env.sut.artist == "")
        #expect(env.sut.artwork == .artworkPlaceholder)
        #expect(env.sut.time == "")
        #expect(env.sut.position == "")
    }

    @Test
    func state_whenResetReceived_expectRemoteReset() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.reset)

        #expect(env.remote.nowPlayingInfo?.keys.isEmpty == true)
    }

    // MARK: - state (stop)

    @Test
    func state_whenStopReceived_expectTimeUpdate() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.stop)

        #expect(env.sut.time == "00:00:00")
    }

    @Test
    func state_whenStopReceived_expectRemoteUpdate() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: MediaItemMock())))

        env.musicPlayer.stateSubject.send(.stop)

        #expect(env.remote.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] as? TimeInterval == 0.0)
    }

    // MARK: - state (clock)

    @Test
    func state_whenClockReceived_expecTimeUpdate() {
        let env = setup()

        env.musicPlayer.stateSubject.send(.clock(60))

        #expect(env.sut.time == "00:01:00")
    }

    @Test
    func state_whenClockReceived_expectRemoteUpdate() {
        let env = setup(musicPlayer: MusicPlayableMock(info: .mock(track: MediaItemMock(playbackDuration: 100))))

        env.musicPlayer.stateSubject.send(.play)
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
