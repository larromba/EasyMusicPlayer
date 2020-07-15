import Foundation
import MediaPlayer

// sourcery: name = Playlist
protocol Playlistable: Mockable {
    func create(shuffled: Bool) -> [MPMediaItem]
    func find(ids: [UInt64]) -> [MPMediaItem]
}

final class Playlist: Playlistable {
    private let authorization: Authorization
    private let mediaQuery: MediaQuery.Type

    init(authorization: Authorization, mediaQuery: MediaQuery.Type) {
        self.authorization = authorization
        self.mediaQuery = mediaQuery

        // note: NSNotification.Name.MPMediaLibraryDidChange indicates when the music library changes.
        // this would be useful for an automatic refresh, but it isn't really required as we create a new playlist
        // when hitting the shuffle button. might be useful at some point
    }

    func create(shuffled: Bool) -> [MPMediaItem] {
        guard authorization.isAuthorized else { return [] }
        if var tracks = mediaQuery.songs().items {
            if shuffled { tracks.shuffle() }
            return tracks
        } else {
            return []
        }
    }

    func find(ids: [MPMediaEntityPersistentID]) -> [MPMediaItem] {
        guard authorization.isAuthorized else { return [] }
        let query = mediaQuery.songs()
        return ids.compactMap { (id: MPMediaEntityPersistentID) -> MPMediaItem? in
            let predicate = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            let items = query.items
            query.removeFilterPredicate(predicate)
            return items?.first // expecting unique id per media item, so take first
        }
    }
}

// MARK: - [MPMediaItem]

private extension Array where Element == MPMediaItem {
    mutating func shuffle() {
        guard !isEmpty else { return }
        (0..<(count - 1)).forEach {
            let remainingCount = count - $0
            let exchangeIndex = $0 + Int(arc4random_uniform(UInt32(remainingCount)))
            swapAt($0, exchangeIndex)
        }
    }
}
