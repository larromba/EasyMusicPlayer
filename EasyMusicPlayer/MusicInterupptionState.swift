import Foundation

struct MusicInterruptionState {
    let isHeadphonesRemovedByMistake: Bool
    let isPlayingInBackground: Bool
    let isAudioSessionInterrupted: Bool
}

extension MusicInterruptionState {
    func copy(isHeadphonesRemovedByMistake: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isHeadphonesRemovedByMistake: isHeadphonesRemovedByMistake,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isPlayingInBackground: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isHeadphonesRemovedByMistake: isHeadphonesRemovedByMistake,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isAudioSessionInterrupted: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isHeadphonesRemovedByMistake: isHeadphonesRemovedByMistake,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isHeadphonesRemovedByMistake: Bool, isAudioSessionInterrupted: Bool) -> MusicInterruptionState {
        return MusicInterruptionState(
            isHeadphonesRemovedByMistake: isHeadphonesRemovedByMistake,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }
}
