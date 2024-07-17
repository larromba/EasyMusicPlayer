import AVFoundation
import Foundation

final class RouteChangeInterruption: MusicInterruption {
    var stage: MusicInterruptionStage = .none
    var isAudioInterrupted = false
    var disconnectedOutputRoutes = [AVAudioSession.Port]()
    var currentOutputRoutes = [AVAudioSession.Port]()

    func didReattachDevice(_ routes: [AVAudioSession.Port]) -> Bool {
        disconnectedOutputRoutes.intersects(routes)
    }
}

// MARK: - Array

private extension Array where Element == AVAudioSession.Port {
    func intersects(_ elements: [AVAudioSession.Port]) -> Bool {
        guard !self.isEmpty && !elements.isEmpty else { return false }
        return !Set(self).isDisjoint(with: Set(elements))
    }
}

// MARK: - CustomStringConvertible

extension RouteChangeInterruption: CustomStringConvertible {
   var description: String {
        return """
        stage: \(stage)
        isAudioInterrupted: \(isAudioInterrupted)
        disconnectedOutputRoutes: \(disconnectedOutputRoutes)
        currentOutputRoutes: \(currentOutputRoutes)
        """
    }
}
