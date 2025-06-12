import Foundation

enum MusicPlayerState {
    case loaded
    case play
    case pause
    case stop
    case reset
    case repeatMode(RepeatMode)
    case clock(TimeInterval)
    case error(MusicPlayerError)
}
