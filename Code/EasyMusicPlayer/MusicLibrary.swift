import Foundation
import MediaPlayer

/// @mockable
protocol MusicLibraryable {
    func makePlaylist(isShuffled: Bool) -> [MPMediaItem]
    func findTracks(with ids: [MPMediaEntityPersistentID]) -> [MPMediaItem]
    func areTrackIDsValid(_ ids: [MPMediaEntityPersistentID]) -> Bool
}

final class MusicLibrary: MusicLibraryable {
    private var libraryQuery: MPMediaQuery {
        MPMediaQuery.songs()
    }

    func makePlaylist(isShuffled: Bool) -> [MPMediaItem] {
        guard let tracks = libraryQuery.items else {
            return []
        }
        return isShuffled ? tracks.shuffled() : tracks
    }

    func findTracks(with ids: [MPMediaEntityPersistentID]) -> [MPMediaItem] {
        let query = libraryQuery
        return ids.compactMap { (id: MPMediaEntityPersistentID) -> MPMediaItem? in
            let predicate = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            let items = query.items
            query.removeFilterPredicate(predicate)
            return items?.first // expecting unique id per media item, so take first
        }
    }

    func areTrackIDsValid(_ ids: [MPMediaEntityPersistentID]) -> Bool {
        let items = libraryQuery.items ?? []

        // if the count is different, then a track got deleted from / added to the libary
        guard items.count == ids.count else {
            return false
        }

        // if the count is the same, check all the tracks are still in the library
        let refreshedItems = findTracks(with: ids)
        guard refreshedItems.count == ids.count else {
            return false
        }

        return true
    }
}
