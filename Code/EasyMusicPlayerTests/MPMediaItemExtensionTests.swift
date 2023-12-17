@testable import EasyMusicPlayer
import MediaPlayer
import XCTest

final class MPMediaItemExtensionTests: XCTestCase {
    func test_track_whenDashFormat_expectArtistAndTitleValues() {
        let sut = MediaItemMock(artist: "", title: "   arkist   -   fill my coffee  ")

        XCTAssertEqual(sut.resolvedArtist, "arkist")
        XCTAssertEqual(sut.resolvedTitle, "fill my coffee")
    }

    func test_track_whenDashInArtistAndTitle_expectArtistAndTitleValues() {
        let sut = MediaItemMock(artist: "", title: "   ark-ist   -   fi-ll my coffee  ")

        XCTAssertEqual(sut.resolvedArtist, "ark-ist")
        XCTAssertEqual(sut.resolvedTitle, "fi-ll my coffee")
    }

    func test_track_whenNotDashFormat_expectArtistAndTitleValues() {
        let sut = MediaItemMock(artist: "", title: "   arkist   -   fill my - coffee  ")

        XCTAssertEqual(sut.resolvedArtist, L10n.unknownArtist)
        XCTAssertEqual(sut.resolvedTitle, "   arkist   -   fill my - coffee  ")
    }

    func test_track_whenEmpty_expectDefaultValues() {
        let sut = MediaItemMock(artist: "", title: "")

        XCTAssertEqual(sut.resolvedArtist, L10n.unknownArtist)
        XCTAssertEqual(sut.resolvedTitle, L10n.unknownTrack)
    }
}
