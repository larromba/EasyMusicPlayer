import Foundation
import MediaPlayer

struct MusicPlayerState {
    let isPlaying: Bool
    let volume: Float
    let currentTrackIndex: Int
    let totalTracks: Int
    let currentTrack: MPMediaItem
    let time: TimeInterval
    let playState: PlayState
    let repeatState: RepeatState
}
