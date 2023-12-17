import Foundation
import MediaPlayer

/// @mockable
protocol Playlistable {
    func create(shuffled: Bool) -> [MPMediaItem]
    func find(ids: [UInt64]) -> [MPMediaItem]
}

final class Playlist: Playlistable {
    func create(shuffled: Bool) -> [MPMediaItem] {
        if var tracks = MPMediaQuery.songs().items {
            if shuffled { tracks.shuffle() }
            return tracks
        } else {
            return []
        }
    }

    func find(ids: [MPMediaEntityPersistentID]) -> [MPMediaItem] {
        let query = MPMediaQuery.songs()
        return ids.compactMap { (id: MPMediaEntityPersistentID) -> MPMediaItem? in
            let predicate = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            let items = query.items
            query.removeFilterPredicate(predicate)
            return items?.first // expecting unique id per media item, so take first
        }
    }
}

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
