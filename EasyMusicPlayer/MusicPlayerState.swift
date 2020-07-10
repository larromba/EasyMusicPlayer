import Foundation
import MediaPlayer

struct MusicServiceState {
    let isPlaying: Bool
    let volume: Float
    let currentTrackIndex: Int
    let totalTracks: Int
    let currentTrack: Track
    let time: TimeInterval
    let playState: PlayState
    let repeatState: RepeatState
}

extension MusicServiceState {
    func copy(repeatState: RepeatState) -> MusicServiceState {
        return MusicServiceState(
            isPlaying: isPlaying,
            volume: volume,
            currentTrackIndex: currentTrackIndex,
            totalTracks: totalTracks,
            currentTrack: currentTrack,
            time: time,
            playState: playState,
            repeatState: repeatState
        )
    }
}
