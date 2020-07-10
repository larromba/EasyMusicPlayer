@testable import EasyMusic
import Foundation
import MediaPlayer

final class MockMediaItem: MPMediaItem {
    static var playbackDuration: TimeInterval = 60 * 3.5 // 3.5mins

    private let _artist: String?
    private let _title: String?
    private let _image: UIImage
    private let _id: MPMediaEntityPersistentID

    override var artist: String? { return _artist }
    override var title: String? { return _title }
    override var playbackDuration: TimeInterval { return type(of: self).playbackDuration }
    override var artwork: MPMediaItemArtwork { return MPMediaItemArtwork(boundsSize: .zero) { _ in self._image } }
    override var assetURL: URL { return .mock }
    override var persistentID: MPMediaEntityPersistentID { return _id }

    init(artist: String? = nil, title: String? = nil, image: UIImage = UIImage(), id: MPMediaEntityPersistentID = 0) {
        _artist = artist
        _title = title
        _image = image
        _id = id
        super.init()
    }

    init(track: Track) {
        _artist = track.artist
        _title = track.title
        _image = track.artwork ?? UIImage()
        _id = track.id
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MPMediaItem {
    static var mock: MPMediaItem {
        return MockMediaItem()
    }

    static func mock(id: MPMediaEntityPersistentID) -> MPMediaItem {
        return MockMediaItem(id: id)
    }
}
