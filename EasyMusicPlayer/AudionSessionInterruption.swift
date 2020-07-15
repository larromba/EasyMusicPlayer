import Foundation

final class AudioSessionInterruption: Interruption {
    var stage: InterruptionStage = .none
    var isAudioInterrupted: Bool = false
}
