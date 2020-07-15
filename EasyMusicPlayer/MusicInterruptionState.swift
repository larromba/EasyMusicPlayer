import Foundation

struct MusicInterruptionState {
    private var interruptions: [Interruption] {
        return [routeChangeInterruption, audioSessionInterruption]
    }
    var routeChangeInterruption: RouteChangeInterruption
    var audioSessionInterruption: AudioSessionInterruption
    var isPlaying: Bool
    var isPlayingInBackground: Bool
}

extension MusicInterruptionState {
    var isAllInterruptionsEnded: Bool {
        return interruptions.filter { $0.stage == .start }.isEmpty
    }
    var isAudioInterrupted: Bool {
        return !interruptions.filter { $0.isAudioInterrupted }.isEmpty
    }
    var isExpectedToContinue: Bool {
        return !isPlaying && isAudioInterrupted && isAllInterruptionsEnded
    }

    func finish() {
        interruptions.forEach { $0.reset() }
    }
}

extension MusicInterruptionState: CustomStringConvertible {
    var description: String {
        return """
        -- MusicInterruptionState --
        routeChangeInterruption:
        \(routeChangeInterruption)

        audioSessionInterruption:
        \(audioSessionInterruption)

        isAllInterruptionsEnded: \(isAllInterruptionsEnded)
        isAudioInterrupted: \(isAudioInterrupted)
        isExpectedToContinue: \(isExpectedToContinue)
        """
    }
}
