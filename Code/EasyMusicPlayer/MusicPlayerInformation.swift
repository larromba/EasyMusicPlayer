import MediaPlayer

struct MusicPlayerInformation {
    let track: CurrentTrackInformation
    let tracks: [MPMediaItem]
    let time: TimeInterval // seconds
    let isPlaying: Bool
    let repeatMode: RepeatMode
}

struct CurrentTrackInformation {
    let item: MPMediaItem?
    let index: Int
    var number: Int { index + 1 }
    var duration: TimeInterval { item?.playbackDuration ?? 0 }
}
