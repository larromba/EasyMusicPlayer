import AVFoundation
import Foundation

struct MusicInterruptionState {
    var disconnected: [AVAudioSession.Port]
    var isDisconnected: Bool {
        return !disconnected.isEmpty
    }
    var current: [AVAudioSession.Port]
    var isAvailable: Bool {
        return !current.isEmpty
    }
    var isPlaying: Bool
    var isPlayingInBackground: Bool
    var isExpectedToContinue: Bool
    var isAudioSessionInterrupted: Bool
}
