import Foundation

enum MusicPlayerState {
    case play
    case pause
    case stop
    case repeatMode(RepeatMode)
    case clock(TimeInterval)
    case error(MusicPlayerError)
}
