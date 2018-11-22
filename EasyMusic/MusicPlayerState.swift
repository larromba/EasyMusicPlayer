import Foundation
import MediaPlayer

struct MusicPlayerState {
    let isPlaying: Bool
    let volume: Float
    let currentTrackNumber: Int
    let numOfTracks: Int
    let currentTrack: MPMediaItem
    let time: TimeInterval
    let playState: PlayState
    let repeatState: RepeatState
}
