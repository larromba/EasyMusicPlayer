@testable import EasyMusicPlayer
import MediaPlayer

// MARK: - MediaItemMock

// swiftlint:disable identifier_name
final class MediaItemMock: MPMediaItem {
    var _artist = ""
    override var artist: String { return _artist }

    var _title = ""
    override var title: String { return _title }

    var _playbackDuration: TimeInterval = 0
    override var playbackDuration: TimeInterval { return _playbackDuration }

    var _artwork: MPMediaItemArtwork?
    override var artwork: MPMediaItemArtwork? { return _artwork }

    var _assetUrl = URL(fileURLWithPath: "")
    override var assetURL: URL { return _assetUrl }

    private let _persistentID: MPMediaEntityPersistentID = 0
    override var persistentID: MPMediaEntityPersistentID { return _persistentID }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(
        artist: String = "",
        title: String = "",
        artwork: MPMediaItemArtwork? = nil,
        playbackDuration: TimeInterval = 0
    ) {
        _artist = artist
        _title = title
        _artwork = artwork
        _playbackDuration = playbackDuration
        super.init()
    }

    override func value(forProperty property: String) -> Any? {
        return nil
    }
}

extension MPMediaItem {
    static func mock(
        artist: String = "",
        title: String = "",
        artwork: MPMediaItemArtwork? = nil,
        playbackDuration: TimeInterval = 0
    ) -> MediaItemMock {
        MediaItemMock(
            artist: artist,
            title: title,
            artwork: artwork,
            playbackDuration: playbackDuration
        )
    }
}

// MARK: - MPMediaItemArtwork

extension MPMediaItemArtwork {
    static let mock = MPMediaItemArtwork(boundsSize: .zero) { _ in return UIImage() }
}

// MARK: - MusicPlayerInformation

extension MusicPlayerInformation {
    static func mock(
        item: MPMediaItem? = nil,
        index: Int = 0,
        tracks: [MPMediaItem] = [],
        time: TimeInterval = 0,
        isPlaying: Bool = false,
        repeatMode: RepeatMode = .none
    ) -> MusicPlayerInformation {
        MusicPlayerInformation(
            track: CurrentTrackInformation(
                item: item,
                index: index
            ),
            tracks: tracks,
            time: time,
            isPlaying: isPlaying,
            repeatMode: repeatMode
        )
    }
}

// MARK: - DragGestureMock

final class DragGestureMock: Draggable {
    var _startLocation: CGPoint
    var startLocation: CGPoint { return _startLocation }

    var _velocity: CGSize
    var velocity: CGSize { return _velocity }

    var _translation: CGSize
    var translation: CGSize { return _translation }

    var _predictedEndTranslation: CGSize
    var predictedEndTranslation: CGSize { return _predictedEndTranslation }

    init(
        startLocation: CGPoint = .zero,
        velocity: CGSize = .zero,
        translation: CGSize = .zero,
        predictedEndTranslation: CGSize = .zero
    ) {
        _startLocation = startLocation
        _velocity = velocity
        _translation = translation
        _predictedEndTranslation = predictedEndTranslation
    }
}
