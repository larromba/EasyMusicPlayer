import Foundation

protocol MusicInterruption: AnyObject, CustomStringConvertible {
    var stage: MusicInterruptionStage { get set }
    var isAudioInterrupted: Bool { get set }

    func reset()
}

// MARK: - CustomStringConvertible

extension MusicInterruption {
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
