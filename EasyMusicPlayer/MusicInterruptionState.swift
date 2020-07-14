import Foundation

struct MusicInterruptionState {
    let isHeadphonesAttached: Bool
    let isPlayingInBackground: Bool
    let isAudioSessionInterrupted: Bool
}

extension MusicInterruptionState {
    func copy(isHeadphonesAttached: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isHeadphonesAttached: isHeadphonesAttached,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isPlayingInBackground: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isHeadphonesAttached: isHeadphonesAttached,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isAudioSessionInterrupted: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isHeadphonesAttached: isHeadphonesAttached,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isHeadphonesRemovedByMistake: Bool, isAudioSessionInterrupted: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isHeadphonesAttached: isHeadphonesAttached,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }
}
