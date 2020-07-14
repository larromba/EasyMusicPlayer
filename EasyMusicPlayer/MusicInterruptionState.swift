import Foundation

struct MusicInterruptionState {
    let isOutputAvailable: Bool
    let isPlayingInBackground: Bool
    let isAudioSessionInterrupted: Bool
}

extension MusicInterruptionState {
    func copy(isOutputAvailable: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isOutputAvailable: isOutputAvailable,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isPlayingInBackground: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isOutputAvailable: isOutputAvailable,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isAudioSessionInterrupted: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isOutputAvailable: isOutputAvailable,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isHeadphonesRemovedByMistake: Bool, isAudioSessionInterrupted: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isOutputAvailable: isOutputAvailable,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }
}
