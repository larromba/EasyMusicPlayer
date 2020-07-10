import Foundation
import Logging
import MediaPlayer

// sourcery: name = TrackManager
protocol TrackManaging: Mockable {
    var library: [Track] { get } // might be slow on large playlists
    // sourcery: value = .empty
    var currentTrack: Track { get }
    // sourcery: value = 0
    var currentTrackIndex: Int { get }
    // sourcery: value = 0
    var totalTracks: Int { get }
    var isLastTrack: Bool { get }

    func loadSavedPlaylist()
    func loadNewPlaylist(shuffled: Bool)
    func cuePrevious() -> Bool
    func cueNext() -> Bool
    func cueStart()
    func cueEnd()
    func removeTrack(atIndex index: Int)
    func setDelegate(_ delegate: TrackManagerDelegate)
}

protocol TrackManagerDelegate: AnyObject {
    func trackManager(_ manager: TrackManaging, updatedTrack track: Track)
}

final class TrackManager: TrackManaging {
    private let userService: UserServicing
    private let authorization: Authorization
    private let playlist: Playlistable
    private var lastTrack: Track {
        guard let track = tracks.last else { return .empty }
        return Track(mediaItem: track, delegate: nil)
    }
    private var tracks: [MPMediaItem] = []
    private weak var delegate: TrackManagerDelegate?
    private(set) var currentTrackIndex: Int = 0 {
        didSet {
            guard currentTrackIndex >= 0, currentTrackIndex < tracks.count else { return }
            currentTrack = Track(mediaItem: tracks[currentTrackIndex], delegate: self)
            userService.currentTrackID = currentTrack.id
        }
    }
    private(set) var currentTrack: Track
    var library: [Track] {
        return tracks.map { Track(mediaItem: $0) }
    }
    var totalTracks: Int {
        return tracks.count
    }
    var isLastTrack: Bool {
        return currentTrack == lastTrack
    }

    init(userService: UserServicing, authorization: Authorization, playlist: Playlistable) {
        self.userService = userService
        self.authorization = authorization
        self.playlist = playlist
        currentTrack = .empty
    }

    func setDelegate(_ delegate: TrackManagerDelegate) {
        self.delegate = delegate
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
        currentTrackIndex = trackIDs.firstIndex(of: currentTrackID) ?? 0
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

// MARK: - DurationDelegate

extension TrackManager: DurationDelegate {
    func duration(_ duration: Duration, didUpdateTime time: TimeInterval) {
        logMagic("silence detected: got new track duration \(time)")
        delegate?.trackManager(self, updatedTrack: currentTrack)
    }
}
