import MediaPlayer
import UIKit

struct Track {
    let artist: String
    let title: String
    let duration: TimeInterval
    let url: URL?
    var artwork: UIImage? {
        return mediaItemArtwork?.image(at: artworkSize)
    }

    private let mediaItemArtwork: MPMediaItemArtwork?
    private let artworkSize: CGSize

    init(mediaItem: MPMediaItem, artworkSize: CGSize) {
        self.artworkSize = artworkSize
        artist = mediaItem.resolvedArtist
        title = mediaItem.resolvedTitle
        duration = mediaItem.playbackDuration
        mediaItemArtwork = mediaItem.artwork
        url = mediaItem.assetURL
    }
}

// MARK: - Equatable

extension Track: Equatable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        return (lhs.artist == rhs.artist && lhs.title == rhs.title && lhs.url == rhs.url)
    }
}

// MARK: - MPMediaItem

private extension MPMediaItem {
    var resolvedArtist: String {
        guard let artist = artist, !artist.isEmpty else {
            return L10n.unknownArtist
        }
        return artist
    }

    var resolvedTitle: String {
        guard let title = title, !title.isEmpty else {
            return L10n.unknownTrack
        }
        return title
    }
}
