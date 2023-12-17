@testable import EasyMusicPlayer
import MediaPlayer
import XCTest

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var musicPlayer: MusicPlayableMock!
    private var soundEffects: SoundEffectingMock!
    private var queue: QueueMock!
    private var sut: SearchViewModel!

    override func setUpWithError() throws {
        setup()
    }

    override func tearDownWithError() throws {
        musicPlayer = nil
        soundEffects = nil
        queue = nil
        sut = nil
    }

    // MARK: - init

    func test_init_whenInvoked_expectStateChanges() {
        setup(wait: false)

        XCTAssertTrue(sut.isLoading)
        XCTAssertTrue(sut.isListDisabled)
        XCTAssertTrue(sut.isSearchDisabled)

        waitSync()

        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isListDisabled)
        XCTAssertFalse(sut.isSearchDisabled)
    }

    func test_init_whenInvoked_expectTracksSorted() {
        let tracks: [MediaItemMock] = [.mock(artist: "c"), .mock(artist: "b"), .mock(artist: "a")]
        setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        XCTAssertEqual(sut.tracks, tracks.reversed())
    }

    func test_init_givenLargeDataSet_whenInvoked_expectTracksSortedInGoodTime() {
        let tracks = (0..<50_000).map { _ in MediaItemMock(artist: UUID().uuidString, title: UUID().uuidString) }

        measure { setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)), wait: false) }
    }

    // MARK: - select

    func test_select_whenInvoked_expectSoundEffect() {
        soundEffects.playHandler = { XCTAssertEqual($0, .casette) }

        sut.select(.mock())

        XCTAssertEqual(soundEffects.playCallCount, 1)
    }

    func test_select_whenInvoked_expectPlay() {
        sut.select(.mock())

        XCTAssertEqual(musicPlayer.playCallCount, 1)
    }

    func test_select_whenInvoked_expectDone() {
        let expectation = expectation(description: "doneAction invoked")
        setup { expectation.fulfill() }

        sut.select(.mock())

        waitForExpectations(timeout: 1)
    }

    // MARK: - searchText

    func test_searchText_givenEmptyQuery_whenInvoked_expectAllTracks() {
        let tracks = [MediaItemMock.mock()]
        setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        sut.searchText = ""

        XCTAssertEqual(sut.tracks, tracks)
    }

    func test_searchText_givenQuery_whenInvoked_expectStateUpdate() {
        sut.searchText = "foo"

        XCTAssertTrue(sut.isNotFoundTextHidden)
        XCTAssertTrue(sut.isLoading)
        XCTAssertTrue(sut.isListDisabled)
    }

    func test_searchText_givenQuery_whenInvoked_expectAllOperationsCancelled() {
        sut.searchText = "foo"

        XCTAssertEqual(queue.cancelAllOperationsCallCount, 1)
    }

    func test_searchText_givenQueryThatMatchesTracks_whenInvoked_expectFoundTracks_andStateUpdates() {
        let tracks: [MediaItemMock] = [.mock(artist: "apple"), .mock(artist: "banana"), .mock(artist: "pear")]
        setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        sut.searchText = "ap"

        waitSync()
        XCTAssertEqual(sut.tracks, [tracks[0]])
        XCTAssertTrue(sut.isNotFoundTextHidden)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isListDisabled)
    }

    func test_searchText_givenQueryThatMatchesTracks_whenInvoked_expectStateUpdates() {
        let tracks: [MediaItemMock] = [.mock(artist: "apple"), .mock(artist: "banana"), .mock(artist: "pear")]
        setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        sut.searchText = "zed"

        waitSync()
        XCTAssertEqual(sut.tracks.count, 0)
        XCTAssertFalse(sut.isNotFoundTextHidden)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.isListDisabled)
    }

    func test_searchText_givenLargeDataSet_whenInvoked_expectTracksFoundInGoodTime() {
        let tracks = (0..<50_000).map { _ in MediaItemMock(artist: UUID().uuidString, title: UUID().uuidString) }
        setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        measure { sut.searchText = "2" }
    }

    private func setup(
        musicPlayer: MusicPlayableMock = MusicPlayableMock(info: .mock(tracks: [.mock()])),
        soundEffects: SoundEffectingMock = SoundEffectingMock(),
        queue: QueueMock = QueueMock(),
        doneAction: @escaping () -> Void = {},
        wait: Bool = true
    ) {
        self.musicPlayer = musicPlayer
        self.soundEffects = soundEffects
        self.queue = queue
        queue.addOperationHandler = { $0() }
        sut = SearchViewModel(
            musicPlayer: musicPlayer,
            soundEffects: soundEffects,
            queue: queue,
            doneAction: doneAction
        )

        guard wait else { return }
        waitSync() // waits for the first sort opertation to finish
    }
}
