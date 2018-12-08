import Foundation
import Logging
import MediaPlayer

// sourcery: name = TrackManager
protocol TrackManaging: Mockable {
    // sourcery: value = []
    var tracks: [MPMediaItem] { get }
    // sourcery: value = .mock
    var currentTrack: MPMediaItem { get }
    // sourcery: value = 0
    var currentTrackIndex: Int { get }
    // sourcery: value = 0
    var totalTracks: Int { get }

    func loadSavedPlaylist()
    func loadNewPlaylist(shuffled: Bool)
    func cuePrevious() -> Bool
    func cueNext() -> Bool
    func cueStart()
    func cueEnd()
    func removeTrack(atIndex index: Int)
}

final class TrackManager: TrackManaging {
    private let userService: UserServicing
    private let authorization: Authorization
    private let playlist: Playlistable

    init(userService: UserServicing, authorization: Authorization, playlist: Playlistable) {
        self.userService = userService
        self.authorization = authorization
        self.playlist = playlist
    }

    private(set) var tracks: [MPMediaItem] = []
    var currentTrack: MPMediaItem {
        guard currentTrackIndex >= 0, currentTrackIndex < tracks.count else {
            logError("no current track, returning empty MPMediaItem")
            return MPMediaItem()
        }
        return tracks[currentTrackIndex]
    }
    private(set) var currentTrackIndex: Int = 0 {
        didSet {
            guard currentTrackIndex >= 0, currentTrackIndex < tracks.count else { return }
            userService.currentTrackID = currentTrack.persistentID
        }
    }
    var totalTracks: Int {
        return tracks.count
    }

    func loadSavedPlaylist() {
        guard authorization.isAuthorized else {
            tracks = []
            currentTrackIndex = 0
                return
        }
        guard
            let currentTrackID = userService.currentTrackID,
            let trackIDs = userService.trackIDs, !trackIDs.isEmpty else {
                return
        }
        tracks = playlist.find(ids: trackIDs)
        currentTrackIndex = trackIDs.index(of: currentTrackID) ?? 0
    }

    func loadNewPlaylist(shuffled: Bool) {
        guard authorization.isAuthorized else {
            tracks = []
            currentTrackIndex = 0
            return
        }

        tracks = playlist.create(shuffled: shuffled)
        currentTrackIndex = 0
        saveTracks(tracks)
    }

    func cuePrevious() -> Bool {
        let newIndex = currentTrackIndex - 1
        if newIndex < 0 {
            return false
        }

        currentTrackIndex = newIndex
        return true
    }

    func cueNext() -> Bool {
        let newIndex = currentTrackIndex + 1
        if newIndex >= tracks.count {
            return false
        }

        currentTrackIndex = newIndex
        return true
    }

    func cueStart() {
        currentTrackIndex = 0
    }

    func cueEnd() {
        currentTrackIndex = totalTracks - 1
    }

    func removeTrack(atIndex index: Int) {
        tracks.remove(at: index)
        currentTrackIndex -= 1
    }

    // MARK: - Private

    private func saveTracks(_ tracks: [MPMediaItem]) {
        userService.trackIDs = tracks.map { return $0.persistentID }
    }
}
