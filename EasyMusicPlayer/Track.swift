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
		let components = title.components(separatedBy: "-")
		guard components.count == 2 else {
			return []
		}
		return [
			components[0].trimmingCharacters(in: .whitespacesAndNewlines),
			components[1].trimmingCharacters(in: .whitespacesAndNewlines)
		]
	}
}