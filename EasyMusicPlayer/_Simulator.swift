#if DEBUG && targetEnvironment(simulator)
import Foundation
import MediaPlayer

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

final class DummyMediaItem: MPMediaItem {
    private let image = Asset.arkistRendezvousFillYourCoffee.image
    private lazy var mediaItemArtwork = MPMediaItemArtwork(boundsSize: image.size) { _ -> UIImage in
        return self.image
    }
    private let _persistentID: MPMediaEntityPersistentID
    private let _assetUrl: URL
    private let _playbackDuration: TimeInterval
    override var artist: String { return "Arkist" }
    override var title: String { return "Fill Your Coffee" }
    override var playbackDuration: TimeInterval { return _playbackDuration }
    override var artwork: MPMediaItemArtwork? { return mediaItemArtwork }
    override var assetURL: URL { return _assetUrl }
    override var persistentID: MPMediaEntityPersistentID { return _persistentID }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(_ asset: DummyAsset, persistentID: MPMediaEntityPersistentID) {
        _assetUrl = asset.url
        _persistentID = persistentID
        _playbackDuration = asset.playbackDuration
        super.init()
    }
}

final class DummyMediaQuery: MPMediaQuery {
    override var items: [MPMediaItem]? {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] == nil {
            return [DummyMediaItem(.normal, persistentID: 0),
                    DummyMediaItem(.endSilence, persistentID: 1),
                    DummyMediaItem(.normal, persistentID: 2)]
        } else {
            return super.items
        }
    }
}
#endif
