import Foundation
import MediaPlayer

// sourcery: name = NowPlayingInfoCenter
protocol NowPlayingInfoCenter: Mockable {
    var nowPlayingInfo: [String: Any]? { get set }
}
extension MPNowPlayingInfoCenter: NowPlayingInfoCenter {}
