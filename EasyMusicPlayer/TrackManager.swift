import Foundation
import Logging
import MediaPlayer

// sourcery: name = TrackManager
protocol TrackManaging: Mockable {
    var tracks: [MPMediaItem] { get }
    var tracksResolved: [Track] { get } // might be slow on larger collections - use sparingly
    // sourcery: value = 0
    var totalTracks: Int { get }
    var currentTrack: MPMediaItem? { get }
    // sourcery: value = .empty
    var currentTrackResolved: Track { get }
    // sourcery: value = 0
    var currentTrackIndex: Int { get }
    var isLastTrack: Bool { get }

    func loadSavedPlaylist()
    func loadNewPlaylist(shuffled: Bool)
    func prime(_ track: Track) -> Bool
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

// use Track instances / properties for anything displayed on the UI
// use MPMediaItem instances / properties for searching / anything that needs speed
final class TrackManager: TrackManaging {
    private let userService: UserServicing
    private let authorization: Authorization
    private let playlist: Playlistable
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private weak var delegate: TrackManagerDelegate?

    // MARK: - tracks
    private(set) var tracks: [MPMediaItem] = []
    var tracksResolved: [Track] {
        return tracks.map { Track(mediaItem: $0) }
    }
    var totalTracks: Int {
        return tracks.count
    }

    // MARK: - current track
    var currentTrack: MPMediaItem? {
        guard currentTrackIndex >= 0, currentTrackIndex < tracks.count else { return nil }
        return tracks[currentTrackIndex]
    }
    private(set) var currentTrackResolved: Track // not a getter, because the duration could update after it's set
    private(set) var currentTrackIndex: Int = 0 {
        didSet {
            guard let currentTrack = currentTrack else { return }
            currentTrackResolved = Track(mediaItem: currentTrack)
            userService.currentTrackID = currentTrackResolved.id
            resolveDuration(for: currentTrackResolved)
        }
    }

    // MARK: - last track
    private var lastTrack: MPMediaItem? {
        return tracks.last
    }
    private var lastTrackResolved: Track {
        guard let track = lastTrack else { return .empty }
        return Track(mediaItem: track)
    }
    var isLastTrack: Bool {
        return currentTrack == lastTrack
    }

    init(userService: UserServicing, authorization: Authorization, playlist: Playlistable) {
        self.userService = userService
        self.authorization = authorization
        self.playlist = playlist
        currentTrackResolved = .empty
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
                logError("couldn't load saved playlist")
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

    func prime(_ track: Track) -> Bool {
        guard let index = tracks.firstIndex(where: { $0.persistentID == track.id }) else { return false }
        currentTrackIndex = index
        return true
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

    private func resolveDuration(for track: Track) {
        operationQueue.cancelAllOperations()
        operationQueue.addOperation(DurationOperation(track: track) { track in
            logMagic("silence detected: got new track duration \(track.duration)")
            self.currentTrackResolved = track
            self.delegate?.trackManager(self, updatedTrack: self.currentTrackResolved)
        })
    }
}
