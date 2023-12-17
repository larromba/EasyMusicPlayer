import Foundation

struct MusicInterruptionState {
    private var interruptions: [MusicInterruption] {
        return [routeChangeInterruption, audioSessionInterruption]
    }
    let routeChangeInterruption: RouteChangeInterruption
    let audioSessionInterruption: AudioSessionInterruption
    var isPlaying: Bool
    var isPlayingInBackground: Bool

    var isAllInterruptionsEnded: Bool {
        interruptions.filter { $0.stage == .start }.isEmpty
    }
    var isAudioInterrupted: Bool {
        !interruptions.filter { $0.isAudioInterrupted }.isEmpty
    }
    var isExpectedToContinue: Bool {
        !isPlaying && isAudioInterrupted && isAllInterruptionsEnded
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
