import MediaPlayer

/// @mockable
protocol NowPlayingInfoCenter: AnyObject {
    var nowPlayingInfo: [String: Any]? { get set }
}
extension MPNowPlayingInfoCenter: NowPlayingInfoCenter {}
