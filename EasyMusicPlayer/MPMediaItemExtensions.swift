import Foundation
import MediaPlayer

extension MPMediaItem {
    var resolved: Track {
        return Track(mediaItem: self, artworkSize: CGSize(width: 512, height: 512))
    }
}
