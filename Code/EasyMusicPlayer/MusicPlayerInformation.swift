import MediaPlayer

struct MusicPlayerInformation {
    let trackInfo: CurrentTrackInformation
    let tracks: [MPMediaItem]
    let time: TimeInterval // seconds
    let isPlaying: Bool
    let repeatMode: RepeatMode
}
