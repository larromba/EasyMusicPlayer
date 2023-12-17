import Combine
import Foundation
import MediaPlayer

/// @mockable
protocol MusicQueuable: AnyObject {
    var current: MPMediaItem? { get }
    var repeatMode: RepeatMode { get set }
    var index: Int { get }
    var items: [MPMediaItem] { get }

    func prime(_ track: MPMediaItem)
    func item(for position: MusicQueueTrackPosition) -> MPMediaItem?
    func load()
    func create()
    func toggleRepeatMode()
}

// deals with figuring out what comes next
// also writes data to the user service (e.g. current track etc)
// TODO: NSNotification.Name.MPMediaLibraryDidChange indicates when the music library changes.
final class MusicQueue: MusicQueuable {
    var current: MPMediaItem? {
        items[safe: index]
    }
    var repeatMode: RepeatMode {
        didSet { userService.repeatMode = repeatMode }
    }
    private(set) var index = 0 {
        didSet { userService.currentTrackID = current?.persistentID }
    }
    private let playlist: Playlistable
    private let userService: UserServicing

    init(
        playlist: Playlistable = Playlist(),
        userService: UserServicing = UserService()
    ) {
        self.playlist = playlist
        self.userService = userService
        repeatMode = userService.repeatMode ?? .none
    }

    private(set) var items = [MPMediaItem]() {
        didSet { userService.trackIDs = items.map { $0.persistentID } }
    }

    func prime(_ track: MPMediaItem) {
        index = items.firstIndex(where: { $0.persistentID == track.persistentID }) ?? 0
    }

    func item(for position: MusicQueueTrackPosition) -> MPMediaItem? {
        switch position {
        case .current:
            return current
        case .next:
            return cueNext()
        case .previous:
            return cuePrevious()
        }
    }

    func load() {
        guard let trackIDs = userService.trackIDs, !trackIDs.isEmpty else {
            create()
            return
        }
        items = playlist.find(ids: trackIDs)
        guard let trackID = userService.currentTrackID, let track = playlist.find(ids: [trackID]).first else {
            return
        }
        prime(track)
    }

    func create() {
        items = playlist.create(shuffled: true)
        index = 0
    }

    func toggleRepeatMode() {
        repeatMode.toggle()
    }

    private func cueNext() -> MPMediaItem? {
        switch repeatMode {
        case .none:
            guard index + 1 < items.endIndex else {
                return nil
            }
            index += 1
            return current
        case .one:
            return current
        case .all:
            guard index + 1 < items.endIndex else {
                index = items.startIndex
                return current
            }
            index += 1
            return current
        }
    }

    private func cuePrevious() -> MPMediaItem? {
        switch repeatMode {
        case .none:
            guard index - 1 >= items.startIndex else {
                return nil
            }
            index -= 1
            return current
        case .one:
            return current
        case .all:
            guard index - 1 >= items.startIndex else {
                index = items.endIndex - 1
                return current
            }
            index -= 1
            return current
        }
    }
}

