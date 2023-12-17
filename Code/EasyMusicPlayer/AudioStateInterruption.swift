import Foundation

final class AudioSessionInterruption: MusicInterruption {
    var stage: MusicInterruptionStage = .none
    var isAudioInterrupted = false
}
