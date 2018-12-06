import Foundation
import MediaPlayer

// sourcery: name = NowPlayingInfoCenter
protocol NowPlayingInfoCentering: AnyObject, Mockable {
    var nowPlayingInfo: [String: Any]? { get set }
}
extension MPNowPlayingInfoCenter: NowPlayingInfoCentering {}
