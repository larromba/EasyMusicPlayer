@testable import EasyMusicPlayer
import MediaPlayer
import Testing

struct MPMediaItemExtensionTests {
    @Test
    func track_whenDashFormat_expectArtistAndTitleValues() {
        let sut = MediaItemMock(artist: "", title: "   arkist   -   fill my coffee  ")

        #expect(sut.resolvedArtist == "arkist")
        #expect(sut.resolvedTitle == "fill my coffee")
    }

    @Test
    func track_whenDashInArtistAndTitle_expectArtistAndTitleValues() {
        let sut = MediaItemMock(artist: "", title: "   ark-ist   -   fi-ll my coffee  ")

        #expect(sut.resolvedArtist == "ark-ist")
        #expect(sut.resolvedTitle == "fi-ll my coffee")
    }

    @Test
    func track_whenNotDashFormat_expectArtistAndTitleValues() {
        let sut = MediaItemMock(artist: "", title: "   arkist   -   fill my - coffee  ")

        #expect(sut.resolvedArtist == L10n.unknownArtist)
        #expect(sut.resolvedTitle == "   arkist   -   fill my - coffee  ")
    }

    @Test
    func track_whenEmpty_expectDefaultValues() {
        let sut = MediaItemMock(artist: "", title: "")

        #expect(sut.resolvedArtist == L10n.unknownArtist)
        #expect(sut.resolvedTitle == L10n.unknownTrack)
    }
}
