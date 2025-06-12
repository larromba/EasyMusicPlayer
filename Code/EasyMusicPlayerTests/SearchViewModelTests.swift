@testable import EasyMusicPlayer
import MediaPlayer
import Testing

@MainActor
struct SearchViewModelTests: Waitable {
    // MARK: - init

    @Test
    func init_whenInvoked_expectStateChanges() async throws {
        let env = try await setup(wait: false)

        #expect(env.sut.isLoading)
        #expect(env.sut.isListDisabled)
        #expect(env.sut.isSearchDisabled)

        try await waitSync()

        #expect(!env.sut.isLoading)
        #expect(!env.sut.isListDisabled)
        #expect(!env.sut.isSearchDisabled)
    }

    @Test
    func init_whenInvoked_expectTracksSorted() async throws {
        let tracks: [MediaItemMock] = [.mock(artist: "c"), .mock(artist: "b"), .mock(artist: "a")]
        let env = try await setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        #expect(env.sut.tracks == tracks.reversed())
    }

    // MARK: - select

    @Test
    func select_whenInvoked_expectSoundEffect() async throws {
        let env = try await setup()
        var soundEffect: SoundEffect?
        env.soundEffects.playHandler = { soundEffect = $0 }

        env.sut.select(.mock())

        #expect(env.soundEffects.playCallCount == 1)
        #expect(soundEffect == .casette)
    }

    @Test
    func select_whenInvoked_expectPlay() async throws {
        let env = try await setup()
        env.sut.select(.mock())

        #expect(env.musicPlayer.playCallCount == 1)
    }

    @Test
    func select_whenInvoked_expectDone() async throws {
        var isDone = false
        let env = try await setup { isDone = true }

        env.sut.select(.mock())

        try await waitSync()
        #expect(isDone)
    }

    // MARK: - searchText

    @Test
    func searchText_givenEmptyQuery_whenInvoked_expectAllTracks() async throws {
        let tracks = [MediaItemMock.mock()]
        let env = try await setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        env.sut.searchText = ""

        #expect(env.sut.tracks == tracks)
    }

    @Test
    func searchText_givenQuery_whenInvoked_expectStateUpdate() async throws {
        let env = try await setup(completeOperations: false)

        env.sut.searchText = "foo"

        #expect(env.sut.isNotFoundTextHidden)
        #expect(env.sut.isLoading)
        #expect(env.sut.isListDisabled)
    }

    @Test
    func searchText_givenQuery_whenInvoked_expectAllOperationsCancelled() async throws {
        let env = try await setup()

        env.sut.searchText = "foo"

        try await waitSync()
        #expect(env.queue.cancelAllOperationsCallCount == 1)
    }

    @Test
    func searchText_whenInvoked_expectThrottled() async throws {
        let env = try await setup()

        env.sut.searchText = "foo1"
        env.sut.searchText = "foo2"
        env.sut.searchText = "foo3"

        try await waitSync(for: 1.0)

        env.sut.searchText = "foo1"
        env.sut.searchText = "foo2"
        env.sut.searchText = "foo3"

        try await waitSync(for: 1.0)

        #expect(env.queue.addOperationCallCount == 2)
    }

    @Test
    func searchText_givenDuplicateQuery_whenInvoked_expectDuplicatesRemoved() async throws {
        let env = try await setup()

        env.sut.searchText = "foo"

        try await waitSync(for: 1.0)

        env.sut.searchText = "foo"

        try await waitSync(for: 1.0)

        #expect(env.queue.addOperationCallCount == 1)
    }

    @Test
    func searchText_givenQueryThatMatchesTracks_whenInvoked_expectFoundTracks_andStateUpdates() async throws {
        let tracks: [MediaItemMock] = [.mock(artist: "apple"), .mock(artist: "banana"), .mock(artist: "pear")]
        let env = try await setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        env.sut.searchText = "ap"

        try await waitSync()
        #expect(env.sut.tracks == [tracks[0]])
        #expect(env.sut.isNotFoundTextHidden)
        #expect(!env.sut.isLoading)
        #expect(!env.sut.isListDisabled)
    }

    @Test
    func searchText_givenQueryThatMatchesTracks_whenInvoked_expectStateUpdates()  async throws {
        let tracks: [MediaItemMock] = [.mock(artist: "apple"), .mock(artist: "banana"), .mock(artist: "pear")]
        let env = try await setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        env.sut.searchText = "zed"

        try await waitSync()
        #expect(env.sut.tracks.count == 0)
        #expect(!env.sut.isNotFoundTextHidden)
        #expect(!env.sut.isLoading)
        #expect(!env.sut.isListDisabled)
    }

    private func setup(
        musicPlayer: MusicPlayableMock = MusicPlayableMock(info: .mock(tracks: [.mock()])),
        soundEffects: SoundEffectingMock = SoundEffectingMock(),
        queue: QueueMock = QueueMock(),
        doneAction: @escaping () -> Void = {},
        completeOperations: Bool = true,
        wait: Bool = true
    ) async throws -> Environmemnt {
        if completeOperations {
            queue.addOperationBlockHandler = { $0() }
            queue.addOperationHandler = { $0.main() }
        }
        let env = Environmemnt(
            musicPlayer: musicPlayer,
            soundEffects: soundEffects,
            queue: queue,
            sut: SearchViewModel(
                musicPlayer: musicPlayer,
                soundEffects: soundEffects,
                queue: queue,
                doneAction: doneAction
            )
        )
        guard wait else { return env }
        try await waitSync() // waits for the first sort opertation to finish
        return env
    }
}

extension SearchViewModelTests {
    struct Environmemnt {
        let musicPlayer: MusicPlayableMock
        let soundEffects: SoundEffectingMock
        let queue: QueueMock
        let sut: SearchViewModel
    }
}
