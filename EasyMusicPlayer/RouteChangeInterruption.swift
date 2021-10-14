import AVFoundation
import Foundation

final class RouteChangeInterruption: Interruption {
    var stage: InterruptionStage = .none
    var isAudioInterrupted = false
    var disconnectedOutputRoutes = [AVAudioSession.Port]()
    var currentOutputRoutes = [AVAudioSession.Port]()

    func didReattachDevice(_ routes: [AVAudioSession.Port]) -> Bool {
        return disconnectedOutputRoutes.intersects(routes)
    }
}

// MARK: - Array

private extension Array where Element == AVAudioSession.Port {
    func intersects(_ items: [AVAudioSession.Port]) -> Bool {
        guard !self.isEmpty && !items.isEmpty else { return false }
        return !Set(self).isDisjoint(with: Set(items))
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
