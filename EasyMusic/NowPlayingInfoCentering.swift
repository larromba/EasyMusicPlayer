import Foundation
import MediaPlayer

protocol NowPlayingInfoCentering: AnyObject {
    var nowPlayingInfo: [String: Any]? { get set }
}
extension MPNowPlayingInfoCenter: NowPlayingInfoCentering {}
