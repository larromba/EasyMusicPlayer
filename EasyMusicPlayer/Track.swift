import Logging
import MediaPlayer
import UIKit

struct Track {
    let artist: String
    let title: String
    let duration: Duration
    let url: URL?
    var artwork: UIImage? {
        return mediaItemArtwork?.image(at: artworkSize)
    }
    let id: MPMediaEntityPersistentID
    private let mediaItemArtwork: MPMediaItemArtwork?
    private let artworkSize: CGSize

    init(mediaItem: MPMediaItem, artworkSize: CGSize = CGSize(width: 512, height: 512),
         delegate: DurationDelegate? = nil) {
        self.artworkSize = artworkSize
        artist = mediaItem.resolvedArtist
        title = mediaItem.resolvedTitle
        duration = Duration(mediaItem.playbackDuration, url: mediaItem.assetURL, delegate: delegate)
        mediaItemArtwork = mediaItem.artwork
        url = mediaItem.assetURL
        id = mediaItem.persistentID
    }
}

extension Track {
    static var empty: Track {
        return Track(mediaItem: MPMediaItem(), artworkSize: .zero)
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
