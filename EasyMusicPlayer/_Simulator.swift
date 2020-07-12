#if DEBUG && targetEnvironment(simulator)
import Foundation
import MediaPlayer

// MARK: - DummyAsset

enum DummyAsset {
    case normal
    case endSilence

    var url: URL {
        switch self {
        case .normal:
            return URL(fileURLWithPath: Bundle.safeMain.infoDictionary!["DummyAudioPath"] as! String)
        case .endSilence:
            return URL(fileURLWithPath: Bundle.safeMain.infoDictionary!["DummyAudioWithSilencePath"] as! String)
        }
    }

    var playbackDuration: TimeInterval {
        switch self {
        case .normal:
            return 290
        case .endSilence:
            return 17
        }
    }
}

// MARK: - DummyMediaItem

final class DummyMediaItem: MPMediaItem {
    private let _artist: String
    override var artist: String { return "Arkist" }

    private let _title: String
    override var title: String { return "Fill Your Coffee" }

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

    init(asset: DummyAsset = .normal, artist: String = "Arkist", title: String = "Fill Your Coffee",
         id: MPMediaEntityPersistentID = 0, image: UIImage? = Asset.arkistRendezvousFillYourCoffee.image) {
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

    init(track: Track) {
        _assetUrl = track.url ?? URL(fileURLWithPath: "")
        _artist = track.artist
        _title = track.title
        _persistentID = track.id
        _playbackDuration = track.duration.value
        if let artwork = track.artwork {
            _artwork = MPMediaItemArtwork(boundsSize: artwork.size) { _ in return artwork }
        } else {
            _artwork = nil
        }
        super.init()
    }
}

extension DummyMediaItem {
    static var mock: DummyMediaItem {
        return DummyMediaItem(asset: .normal, id: 0)
    }

    static func mock(id: MPMediaEntityPersistentID) -> DummyMediaItem {
        return DummyMediaItem(asset: .normal, id: id)
    }
}

// MARK: - DummyMediaQuery

final class DummyMediaQuery: MPMediaQuery {
    override var items: [MPMediaItem]? {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            return [DummyMediaItem(asset: .normal, id: 0),
                    DummyMediaItem(asset: .endSilence, id: 1),
                    DummyMediaItem(asset: .normal, id: 2)]
        } else {
            return super.items
        }
    }
}
#endif
