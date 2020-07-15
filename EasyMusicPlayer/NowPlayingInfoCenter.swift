import Foundation
import MediaPlayer

// sourcery: name = NowPlayingInfoCenter
protocol NowPlayingInfoCenter: AnyObject, Mockable {
    var nowPlayingInfo: [String: Any]? { get set }
}
extension MPNowPlayingInfoCenter: NowPlayingInfoCenter {}
