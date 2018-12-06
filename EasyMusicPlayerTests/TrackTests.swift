@testable import EasyMusic
import MediaPlayer
import XCTest

final class TrackTests: XCTestCase {
    func testDashTrackFormat() {
        // mocks
        let mediaItem = MockMediaItem(title: "   arkist   -   fill my coffee  ")

        // sut
        let track = Track(mediaItem: mediaItem, artworkSize: .zero)

        // test
        XCTAssertEqual(track.artist, "arkist")
        XCTAssertEqual(track.title, "fill my coffee")
    }

    func testFallbackText() {
        // mocks
        let mediaItem = MockMediaItem()

        // sut
        let track = Track(mediaItem: mediaItem, artworkSize: .zero)

        // test
        XCTAssertEqual(track.artist, "Unknown Artist")
        XCTAssertEqual(track.title, "Unknown Title")
    }
}
