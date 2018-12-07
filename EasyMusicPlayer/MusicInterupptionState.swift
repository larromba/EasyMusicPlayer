import Foundation

struct MusicInterupptionState {
    let isHeadphonesRemovedByMistake: Bool
    let isPlayingInBackground: Bool
    let isAudioSessionInterrupted: Bool
}

extension MusicInterupptionState {
    func copy(isHeadphonesRemovedByMistake: Bool) -> MusicInterupptionState {
        return MusicInterupptionState(
            isHeadphonesRemovedByMistake: isHeadphonesRemovedByMistake,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isPlayingInBackground: Bool) -> MusicInterupptionState {
        return MusicInterupptionState(
            isHeadphonesRemovedByMistake: isHeadphonesRemovedByMistake,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isAudioSessionInterrupted: Bool) -> MusicInterupptionState {
        return MusicInterupptionState(
            isHeadphonesRemovedByMistake: isHeadphonesRemovedByMistake,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }

    func copy(isHeadphonesRemovedByMistake: Bool, isAudioSessionInterrupted: Bool) -> MusicInterupptionState {
        return MusicInterupptionState(
            isHeadphonesRemovedByMistake: isHeadphonesRemovedByMistake,
            isPlayingInBackground: isPlayingInBackground,
            isAudioSessionInterrupted: isAudioSessionInterrupted
        )
    }
}
