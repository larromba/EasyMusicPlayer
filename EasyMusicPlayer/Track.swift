import Logging
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
    let id: MPMediaEntityPersistentID
    let albumTitle: String?
    let genre: String?
    private let mediaItemArtwork: MPMediaItemArtwork?
    private let artworkSize: CGSize
}

extension Track {
    init(mediaItem: MPMediaItem, artworkSize: CGSize = CGSize(width: 512, height: 512)) {
        self.artworkSize = artworkSize
        artist = mediaItem.resolvedArtist
        title = mediaItem.resolvedTitle
        duration = mediaItem.playbackDuration
        mediaItemArtwork = mediaItem.artwork
        url = mediaItem.assetURL
        id = mediaItem.persistentID
        albumTitle = mediaItem.albumTitle
        genre = mediaItem.genre
    }

    static var empty: Track {
        return Track(
            artist: "",
            title: "",
            duration: 0,
            url: nil,
            id: 0,
            albumTitle: nil,
            genre: nil,
            mediaItemArtwork: nil,
            artworkSize: .zero
        )
    }

    func copy(duration: TimeInterval) -> Track {
        return Track(
            artist: artist,
            title: title,
            duration: duration,
            url: url,
            id: id,
            albumTitle: albumTitle,
            genre: genre,
            mediaItemArtwork: mediaItemArtwork,
            artworkSize: artworkSize
        )
    }
}

// MARK: - Equatable

extension Track: Equatable {
    static func == (lhs: Track, rhs: Track) -> Bool {
        return (
            lhs.artist == rhs.artist &&
            lhs.title == rhs.title &&
            lhs.url == rhs.url &&
            lhs.id == rhs.id
        )
    }
}

// MARK: - MPMediaItem

private extension MPMediaItem {
    var resolvedArtist: String {
        guard let artist = artist, !artist.isEmpty else {
            if isDashTrackFormat, dashTrackComponents.count == 2 {
                return dashTrackComponents[0]
            }
            return L10n.unknownArtist
        }
        return artist
    }

    var resolvedTitle: String {
        guard let title = title, !title.isEmpty else {
            return L10n.unknownTrack
        }
        if isDashTrackFormat, dashTrackComponents.count == 2 {
            return dashTrackComponents[1]
        }
        return title
    }

    var isDashTrackFormat: Bool {
        guard let title = title else {
            return false
        }
        guard let regex = try? NSRegularExpression(pattern: ".+\\s+\\-\\s+.+", options: [.caseInsensitive]) else {
            assertionFailure("regex shouldn't fail")
            return false
        }
        let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: title.count))
        return matches.count == 1
    }

    var dashTrackComponents: [String] {
        guard let title = title else {
            return []
        }
        guard let regex = try? NSRegularExpression(pattern: "\\s+\\-\\s+", options: [.caseInsensitive]) else {
            assertionFailure("regex shouldn't fail")
            return []
        }
        let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: title.count))
        guard matches.count == 1, let range = Range(matches[0].range, in: title) else {
            logError("dash regex not found")
            return []
        }
        let separator = title[range]
        let components = title.components(separatedBy: separator)
        guard components.count == 2 else {
            logError("unexpected components after separation by dash regex")
            return []
        }
        return [
            components[0].trimmingCharacters(in: .whitespacesAndNewlines),
            components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        ]
    }
}
