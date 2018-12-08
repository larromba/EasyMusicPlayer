import Foundation
import MediaPlayer

// sourcery: name = Playlist
protocol Playlistable: Mockable {
    func create(shuffled: Bool) -> [MPMediaItem]
    func find(ids: [UInt64]) -> [MPMediaItem]
}

final class Playlist: Playlistable {
    private let authorization: Authorization
    private let mediaQuery: MediaQueryable.Type

    init(authorization: Authorization, mediaQuery: MediaQueryable.Type) {
        self.authorization = authorization
        self.mediaQuery = mediaQuery

        // note: NSNotification.Name.MPMediaLibraryDidChange indicates when the music library changes.
        // this would be useful for an automatic refresh, but it isn't really required as we create a new playlist
        // when hitting the shuffle button. perhpas this is needed if we ever bring in track management
    }

    func create(shuffled: Bool) -> [MPMediaItem] {
        guard authorization.isAuthorized else {
            return []
        }

        #if targetEnvironment(simulator)
        final class DummyMediaItem: MPMediaItem {
            private let image = Asset.arkistRendezvousFillYourCoffee.image
            private lazy var mediaItemArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ -> UIImage in
                return self.image
            }
            private let assetUrl = URL(fileURLWithPath: Bundle.safeMain.infoDictionary!["DummyAudioPath"] as! String)

            override var artist: String { return "Arkist" }
            override var title: String { return "Fill Your Coffee" }
            override var playbackDuration: TimeInterval { return 219 }
            override var artwork: MPMediaItemArtwork { return mediaItemArtwork }
            override var assetURL: URL { return assetUrl }
        }
        var tracks = [DummyMediaItem(), DummyMediaItem(), DummyMediaItem()]
        if shuffled { tracks.shuffle() }
        return tracks
        #else
        if var tracks = mediaQuery.songs().items {
            if shuffled { tracks.shuffle() }
            return tracks
        } else {
            return []
        }
        #endif
    }

    func find(ids: [UInt64]) -> [MPMediaItem] {
        let query = MPMediaQuery.songs()
        return ids.compactMap { (id: UInt64) -> [MPMediaItem]? in
            let predicate = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            let items = query.items
            query.removeFilterPredicate(predicate)
            return items
        }.reduce([], +)
    }
}

// MARK: - [MPMediaItem]

private extension Array where Element == MPMediaItem {
    mutating func shuffle() {
        (0..<(count - 1)).forEach {
            let remainingCount = count - $0
            let exchangeIndex = $0 + Int(arc4random_uniform(UInt32(remainingCount)))
            swapAt($0, exchangeIndex)
        }
    }
}
