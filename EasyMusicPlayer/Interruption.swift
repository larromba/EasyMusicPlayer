import Foundation

protocol Interruption: AnyObject, CustomStringConvertible {
    var stage: InterruptionStage { get set }
    var isAudioInterrupted: Bool { get set }

    func reset()
}

// MARK: - CustomStringConvertible

extension Interruption {
    var description: String {
        return """
        stage: \(stage)
        isAudioInterrupted: \(isAudioInterrupted)
        """
    }

    func reset() {
        stage = .none
        isAudioInterrupted = false
    }
}
