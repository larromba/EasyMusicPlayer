import Foundation
import MediaPlayer

final class MockMediaItem: MPMediaItem {
    static var playbackDuration: TimeInterval = 60 * 3.5 // 3.5mins

    private var _artist: String?
    private var _title: String?

    override var artist: String? { return _artist }
    override var title: String? { return _title }
    override var playbackDuration: TimeInterval { return type(of: self).playbackDuration }
    override var artwork: MPMediaItemArtwork { return MPMediaItemArtwork(boundsSize: .zero) { _ in return UIImage() } }
    override var assetURL: URL { return .mock }

    init(artist: String? = nil, title: String? = nil) {
        _artist = artist
        _title = title
        super.init()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MPMediaItem {
    static var mock: MPMediaItem = MockMediaItem()
}
