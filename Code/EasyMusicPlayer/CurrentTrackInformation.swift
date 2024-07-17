import MediaPlayer

struct CurrentTrackInformation {
    let track: MPMediaItem?
    let index: Int
    var number: Int { index + 1 }
    var duration: TimeInterval { track?.playbackDuration ?? 0 }
}
