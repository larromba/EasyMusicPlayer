import AVFoundation
import Foundation

struct MusicInterruptionState {
    let disconnected: [AVAudioSession.Port]
    let current: [AVAudioSession.Port]
    var isAvailable: Bool {
        return !current.isEmpty
    }
    let isPlayingInBackground: Bool
    let isAudioSessionInterrupted: Bool
}

extension MusicInterruptionState {
    func copy(disconnected: [AVAudioSession.Port]) -> MusicInterruptionState {
        return MusicInterruptionState(
            disconnected: disconnected,
            current: current,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(current: [AVAudioSession.Port]) -> MusicInterruptionState {
        return MusicInterruptionState(
            disconnected: disconnected,
            current: current,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isPlayingInBackground: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            disconnected: disconnected,
            current: current,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isAudioSessionInterrupted: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            disconnected: disconnected,
            current: current,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }
}
