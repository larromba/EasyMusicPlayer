@testable import EasyMusic
import MediaPlayer
import XCTest

final class TrackTests: XCTestCase {
    func test_track_whenDashFormat_expectArtistAndTitleValues() {
        // mocks
        let mediaItem = DummyMediaItem(title: "   arkist   -   fill my coffee  ")

        // sut
        let track = Track(mediaItem: mediaItem)

        // test
        XCTAssertEqual(track.artist, "arkist")
        XCTAssertEqual(track.title, "fill my coffee")
    }

    func test_track_whenNotDashFormat_expectArtistAndTitleValues() {
        // mocks
        let mediaItem = DummyMediaItem(title: "   arkist   -   fill my - coffee  ")

        // sut
        let track = Track(mediaItem: mediaItem)

        // test
        XCTAssertEqual(track.artist, "Unknown Artist")
        XCTAssertEqual(track.title, "   arkist   -   fill my - coffee  ")
    }

    func test_track_whenEmpty_expectDefaultValues() {
        // mocks
        let mediaItem = DummyMediaItem()

        // sut
        let track = Track(mediaItem: mediaItem)

        // test
        XCTAssertEqual(track.artist, "Unknown Artist")
        XCTAssertEqual(track.title, "Unknown Title")
    }
}
