import Foundation

enum MusicPlayerState {
    case loaded
    case play
    case pause
    case stop
    case reset
    case repeatMode(RepeatMode)
    case lofi(Bool)
    case distortion(Bool)
    case clock(TimeInterval)
    case error(MusicPlayerError)
}
