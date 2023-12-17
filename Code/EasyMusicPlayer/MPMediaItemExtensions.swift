import MediaPlayer

extension MPMediaItem: Identifiable {
    public var id: MPMediaEntityPersistentID {
        persistentID
    }
}

extension MPMediaItem {
    var sortID: String {
        "\(artist ?? L10n.unknownArtist) - \(title ?? L10n.unknownTrack)"
    }

    var resolvedArtist: String {
        guard let artist = artist, !artist.isEmpty else {
            guard let trackComponents else {
                return L10n.unknownArtist
            }
            return trackComponents.artist
        }
        return artist
    }

    var resolvedTitle: String {
        guard let title, !title.isEmpty else {
            return L10n.unknownTrack
        }
        guard let trackComponents else {
            return title
        }
        return trackComponents.track
    }

    var isDashFormat: Bool {
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

    private struct TrackComponents {
        let artist: String
        let track: String
    }

    private var trackComponents: TrackComponents? {
        guard let title = title else {
            return nil
        }
        guard let regex = try? NSRegularExpression(pattern: "\\s+\\-\\s+", options: [.caseInsensitive]) else {
            assertionFailure("regex shouldn't fail")
            return nil
        }
        let matches = regex.matches(in: title, options: [], range: NSRange(location: 0, length: title.count))
        guard matches.count == 1, let range = Range(matches[0].range, in: title) else {
            logError("dash regex not found")
            return nil
        }
        let separator = title[range]
        let components = title.components(separatedBy: separator)
        guard components.count == 2 else {
            logError("unexpected component count after separation by dash regex")
            return nil
        }
        return TrackComponents(
            artist: components[0].trimmingCharacters(in: .whitespacesAndNewlines),
            track: components[1].trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }
}
