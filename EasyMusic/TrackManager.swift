import Foundation
import MediaPlayer

protocol TrackManaging {
    var allTracks: [MPMediaItem] { get }
    var currentTrack: MPMediaItem { get }
    var currentTrackNumber: Int { get }
    var numOfTracks: Int { get }
    var authorized: Bool { get }

    func createPlaylist() -> [MPMediaItem]
    func authorize(_ completion: @escaping ((_ success: Bool) -> Void)) //TODO: separate class
    func loadTracks()
    func shuffleTracks()
    func cuePrevious() -> Bool
    func cueNext() -> Bool
    func cueStart()
    func cueEnd()
    func removeTrack(atIndex index: Int)
}

// TODO: change this path
let kDummyAudio = "/Users/larromba/Documents/Code Private/EasyMusicPlayer/[TestTunes]/Bounce.mp3"

// TODO: MPMediaQuery
final class TrackManager: TrackManaging {
    private var tracks: [MPMediaItem] = []
    private var trackIndex: Int = 0 {
        didSet {
            userService.currentTrackID = currentTrack.persistentID
        }
    }
    private let userService: UserServicing

    init(userService: UserServicing) {
        self.userService = userService
    }

    var allTracks: [MPMediaItem] {
        return tracks
    }
    var currentResolvedTrack: Track {
        return Track(mediaItem: currentTrack, artworkSize: CGSize(width: 512, height: 512))
    }
    var currentTrack: MPMediaItem {
        guard currentTrackNumber >= 0, currentTrackNumber < tracks.count else {
            assertionFailure("unexpected state")
            return MPMediaItem()
        }
        return tracks[currentTrackNumber]
    }
    var currentTrackNumber: Int {
        return trackIndex
    }
    var numOfTracks: Int {
        return tracks.count
    }
    var authorized: Bool {
        return MPMediaLibrary.authorizationStatus() == .authorized
    }

    func createPlaylist() -> [MPMediaItem] {
        guard authorized else {
            return []
        }

        // TODO: refactor
        #if targetEnvironment(simulator)
            class MockMediaItem: MPMediaItem {
                let image = UIImage(named: "arkist-rendezvous-fill_your_coffee")!
                lazy var mediaItemArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ -> UIImage in
                    return self.image
                }
                let assetUrl = URL(fileURLWithPath: kDummyAudio)

                override var artist: String { return "Arkist" }
                override var title: String { return "Fill Your Coffee" }
                override var playbackDuration: TimeInterval { return 219 }
                override var artwork: MPMediaItemArtwork { return mediaItemArtwork }
                override var assetURL: URL { return assetUrl }
            }

            let tracks = [MockMediaItem(), MockMediaItem(), MockMediaItem()]
            return tracks
        #else
            if let songs = MPMediaQuery.songs().items {
                return songs
            } else {
                return []
            }
        #endif
    }

    // TODO: remove out
    func authorize(_ completion: @escaping ((_ success: Bool) -> Void)) {
        MPMediaLibrary.requestAuthorization({ (status: MPMediaLibraryAuthorizationStatus) in
            DispatchQueue.main.async(execute: {
                completion(status == .authorized)
            })
        })
    }

    func loadTracks() {
        guard authorized else {
            tracks = []
            trackIndex = 0
                return
        }
        guard
            let currentTrackID = userService.currentTrackID,
            let trackIDs = userService.trackIDs, !trackIDs.isEmpty else {
                return
        }
        let query = MPMediaQuery.songs()
        tracks = trackIDs.compactMap { (id: UInt64) -> [MPMediaItem]? in
            let predicate = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            let items = query.items
            query.removeFilterPredicate(predicate)
            return items
        }.reduce([], +)
        trackIndex = trackIDs.index(of: currentTrackID) ?? 0
    }

    func shuffleTracks() {
        guard authorized else {
            tracks = []
            trackIndex = 0
            return
        }

        // NSNotification.Name.MPMediaLibraryDidChange indicates when the music library changes,
        // but an automatic refresh isn't required as we create a new playlist each time
        var playlist = createPlaylist()
        (0..<(playlist.count - 1)).forEach {
            let remainingCount = playlist.count - $0
            let exchangeIndex = $0 + Int(arc4random_uniform(UInt32(remainingCount)))
            playlist.swapAt($0, exchangeIndex)
        }

        tracks = playlist
        trackIndex = 0
        saveTracks(tracks)
    }

    func cuePrevious() -> Bool {
        let newIndex = currentTrackNumber - 1
        if newIndex < 0 {
            return false
        }

        trackIndex = newIndex
        return true
    }

    func cueNext() -> Bool {
        let newIndex = currentTrackNumber + 1
        if newIndex >= tracks.count {
            return false
        }

        trackIndex = newIndex
        return true
    }

    func cueStart() {
        trackIndex = 0
    }

    func cueEnd() {
        trackIndex = numOfTracks - 1
    }

    func removeTrack(atIndex index: Int) {
        tracks.remove(at: index)
        trackIndex -= 1
    }

    // MARK: - Private

    private func saveTracks(_ tracks: [MPMediaItem]) {
        userService.trackIDs = tracks.map { return $0.persistentID }
    }
}
