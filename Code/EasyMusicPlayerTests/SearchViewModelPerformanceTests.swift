@testable import EasyMusicPlayer
import XCTest
import Combine

@MainActor
final class SearchViewModelPerformanceTests: XCTestCase, Sendable {
    private var musicPlayer: MusicPlayableMock!
    private var sut: SearchViewModel!
    private var cancellables = [AnyCancellable]()

    override func setUp() async throws {
        try await super.setUp()
        setup()
    }

    override func tearDown() async throws {
        musicPlayer = nil
        sut = nil
        cancellables.removeAll()
        try await super.tearDown()
    }

    // MARK: - init


    func test_init_givenLargeDataSet_whenInvoked_expectTracksSortedInGoodTime() {
        let expectation = XCTestExpectation(description: "wait")
        let tracks = (0..<50_000).map { _ in
            MediaItemMock(artist: UUID().uuidString, title: UUID().uuidString)
        }

        // start
        let startTime = CFAbsoluteTimeGetCurrent()

        // sut
        setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)), wait: false)

        // end
        sut.$isLoading.dropFirst().sink {
            guard !$0 else { return }
            XCTAssertLessThan(CFAbsoluteTimeGetCurrent() - startTime, 2)
            expectation.fulfill()
        }.store(in: &cancellables)

        wait(for: [expectation], timeout: 5)
    }

    // MARK: - searchText

    func test_searchText_givenLargeDataSet_whenSet_expectTracksFoundInGoodTime() {
        let expectation = XCTestExpectation(description: "wait")
        let tracks = (0..<50_000).map { _ in
            MediaItemMock(artist: UUID().uuidString, title: UUID().uuidString)
        }
        setup(musicPlayer: MusicPlayableMock(info: .mock(tracks: tracks)))

        // start
        let startTime = CFAbsoluteTimeGetCurrent()

        // end
        sut.$isLoading.dropFirst().sink {
            guard !$0 else { return }
            XCTAssertLessThan(CFAbsoluteTimeGetCurrent() - startTime, 2)
            expectation.fulfill()
        }.store(in: &cancellables)

        // sut
        sut.searchText = "0"

        wait(for: [expectation], timeout: 5)
    }

    private func setup(
        musicPlayer: MusicPlayableMock = MusicPlayableMock(info: .mock(tracks: [.mock()])),
        wait: Bool = true
    ) {
        self.musicPlayer = musicPlayer
        let queue = QueueMock()
        queue.addOperationBlockHandler = { $0() }
        queue.addOperationHandler = { $0.main() }
        sut = SearchViewModel(
            musicPlayer: musicPlayer,
            soundEffects: SoundEffectingMock(),
            queue: queue,
            doneAction: {}
        )
        guard wait else { return }
        waitSync() // waits for the first sort opertation to finish
    }
}
