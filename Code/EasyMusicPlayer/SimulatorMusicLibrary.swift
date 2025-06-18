#if DEBUG && targetEnvironment(simulator)
@preconcurrency import MediaPlayer

// MARK: - MPMediaQuery

extension MPMediaQuery {
    /// **CHANGE THIS TO TEST DIFFERENT LIBRARIES ON THE SIMULATOR**
    static func songs() -> MPMediaQuery {
//        SimulatorMediaQuery(tracks: smallLibary)
        SimulatorMediaQuery(tracks: largeLibrary)
    }

    private static let smallLibary = [
        SimulatorMediaItem(asset: .track1, artist: "Foo", title: "Apple", id: 0),
        SimulatorMediaItem(asset: .track2, artist: "Bar", title: "Orange", id: 1),
        SimulatorMediaItem(asset: .track3, artist: "The Foo Bars", title: "Pear", id: 2)
    ]

    private static let largeLibrary: [MPMediaItem] = {
        return (0..<50_000).map {
            SimulatorMediaItem(asset: .random, artist: UUID().uuidString, title: UUID().uuidString, id: $0)
        }
    }()
}

// MARK: - SimulatorMediaItem

final class SimulatorMediaItem: MPMediaItem, @unchecked Sendable {
    enum MediaAsset: Int {
        case track1
        case track2
        case track3

        static var random: MediaAsset {
            MediaAsset(rawValue: .random(in: 0..<3))!
        }

        var url: URL {
            // if it's the ci, use the test bundle's audio track (else the ci fails)
            guard !ProcessInfo.isCI else {
                guard let audioPath = ProcessInfo.processInfo.environment["audio"] else { return .empty }
                return URL(fileURLWithPath: audioPath)
            }

            // if it's not the ci, use the audio specified in the info dictionary
            guard let trackPaths = Bundle.safeMain.infoDictionary?["Track Paths"] as? [String: String] else { return .empty }
            switch self {
            case .track1:
                guard let trackPath = trackPaths["Track #1"] as String? else { return .empty }
                return URL(fileURLWithPath: trackPath)
            case .track2:
                guard let trackPath = trackPaths["Track #2"] as String? else { return .empty }
                return URL(fileURLWithPath: trackPath)
            case .track3:
                guard let trackPath = trackPaths["Track #3"] as String? else { return .empty }
                return URL(fileURLWithPath: trackPath)
            }
        }

        var playbackDuration: TimeInterval {
            // if it's the ci, use the test bundle's audio track length
            guard !ProcessInfo.isCI else { return 40 }

            // if it's not the ci, return the track lengths for the audio specified in the info dictionary
            switch self {
            case .track1: return 32
            case .track2: return 31
            case .track3: return 34
            }
        }
    }

    private let _artist: String
    override var artist: String { return _artist }

    private let _title: String
    override var title: String { return _title }

    private let _playbackDuration: TimeInterval
    override var playbackDuration: TimeInterval { return _playbackDuration }

    private let _artwork: MPMediaItemArtwork?
    override var artwork: MPMediaItemArtwork? { return _artwork }

    private let _assetUrl: URL
    override var assetURL: URL { return _assetUrl }

    private let _persistentID: MPMediaEntityPersistentID
    override var persistentID: MPMediaEntityPersistentID { return _persistentID }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        asset: MediaAsset = .track1,
        artist: String = "Arkist",
        title: String = "Fill Your Coffee",
        id: MPMediaEntityPersistentID = 0,
        image: UIImage? = .arkistRendezvousFillYourCoffee
    ) {
        _assetUrl = asset.url
        _artist = artist
        _title = title
        _persistentID = id
        _playbackDuration = asset.playbackDuration
        if let image = image {
            _artwork = MPMediaItemArtwork(boundsSize: image.size) { _ in return image }
        } else {
            _artwork = nil
        }
        super.init()
    }

    override var hash: Int {
        return Int(_persistentID)
    }

    // fix crash: iOS 14
    override func value(forProperty property: String) -> Any? {
        return nil
    }
}

// MARK: - SimulatorMediaQuery

final class SimulatorMediaQuery: MPMediaQuery {
    private let _items: [MPMediaItem]
    private var id: MPMediaEntityPersistentID?

    init(tracks: [MPMediaItem]) {
        _items = tracks
        super.init(filterPredicates: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var items: [MPMediaItem]? {
        if let id = id {
            return [_items[Int(id)]]
        } else {
            return _items
        }
    }

    override func addFilterPredicate(_ predicate: MPMediaPredicate) {
        guard let predicate = predicate as? MPMediaPropertyPredicate else { return }
        id = predicate.value as? MPMediaEntityPersistentID
    }

    override func removeFilterPredicate(_ predicate: MPMediaPredicate) {
        id = nil
    }
}

private extension URL {
    static let empty = URL(fileURLWithPath: "")
}

private extension ProcessInfo {
    static var isCI: Bool {
        ProcessInfo.processInfo.environment["TRAVIS"] == "1"
    }
}
#endif
