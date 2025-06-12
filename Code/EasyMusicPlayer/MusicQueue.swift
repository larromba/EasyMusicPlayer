import Combine
import Foundation
@preconcurrency import MediaPlayer

/// @mockable
protocol MusicQueuable: AnyObject, Sendable {
    var currentTrack: MPMediaItem? { get }
    var repeatMode: RepeatMode { get set }
    var currentTrackIndex: Int { get }
    var tracks: [MPMediaItem] { get }

    func prime(_ track: MPMediaItem)
    func track(for position: MusicQueueTrackPosition) -> MPMediaItem?
    func load()
    func create()
    func hasUpdates() -> Bool
    func toggleRepeatMode()
}

/// deals with figuring out what comes next
/// also writes data to the user service (e.g. current track etc)
final class MusicQueue: MusicQueuable {
    var currentTrack: MPMediaItem? {
        tracks[safe: currentTrackIndex]
    }
    var repeatMode: RepeatMode {
        get { userService.repeatMode ?? .none }
        set { userService.repeatMode = newValue }
    }
    private(set) var currentTrackIndex: Int {
        get { _currentTrackIndex.withValue { $0 } }
        set {
            _currentTrackIndex.setValue(newValue)
            userService.currentTrackID = currentTrack?.persistentID
        }
    }
    private(set) var tracks: [MPMediaItem] {
        get { _tracks.withValue { $0 } }
        set {
            _tracks.setValue(newValue)
            userService.trackIDs = newValue.map { $0.persistentID }
        }
    }

    private let musicLibrary: MusicLibraryable
    private let userService: UserServicing
    private let _tracks = LockIsolated<[MPMediaItem]>([])
    private let _currentTrackIndex = LockIsolated<Int>(0)

    init(
        musicLibrary: MusicLibraryable = MusicLibrary(),
        userService: UserServicing = UserService()
    ) {
        self.musicLibrary = musicLibrary
        self.userService = userService
    }

    func prime(_ track: MPMediaItem) {
        currentTrackIndex = tracks.firstIndex(where: { $0.persistentID == track.persistentID }) ?? 0
    }

    func track(for position: MusicQueueTrackPosition) -> MPMediaItem? {
        switch position {
        case .current:
            return currentTrack
        case .next:
            return cueNext()
        case .previous:
            return cuePrevious()
        }
    }

    func load() {
        guard let trackIDs = userService.trackIDs, !trackIDs.isEmpty, musicLibrary.areTrackIDsValid(trackIDs) else {
            create()
            return
        }
        tracks = musicLibrary.findTracks(with: trackIDs)
        guard let trackID = userService.currentTrackID, let track = musicLibrary.findTracks(with: [trackID]).first else {
            return
        }
        prime(track)
    }

    func create() {
        tracks = musicLibrary.makePlaylist(isShuffled: true)
        currentTrackIndex = 0
    }

    func hasUpdates() -> Bool {
        !musicLibrary.areTrackIDsValid(tracks.map { $0.id })
    }

    func toggleRepeatMode() {
        repeatMode.toggle()
    }

    private func cueNext() -> MPMediaItem? {
        switch repeatMode {
        case .none:
            guard currentTrackIndex + 1 < tracks.endIndex else {
                return nil
            }
            currentTrackIndex += 1
            return currentTrack
        case .one:
            return currentTrack
        case .all:
            guard currentTrackIndex + 1 < tracks.endIndex else {
                currentTrackIndex = tracks.startIndex
                return currentTrack
            }
            currentTrackIndex += 1
            return currentTrack
        }
    }

    private func cuePrevious() -> MPMediaItem? {
        switch repeatMode {
        case .none:
            guard currentTrackIndex - 1 >= tracks.startIndex else {
                return nil
            }
            currentTrackIndex -= 1
            return currentTrack
        case .one:
            return currentTrack
        case .all:
            guard currentTrackIndex - 1 >= tracks.startIndex else {
                currentTrackIndex = tracks.endIndex - 1
                return currentTrack
            }
            currentTrackIndex -= 1
            return currentTrack
        }
    }
}

