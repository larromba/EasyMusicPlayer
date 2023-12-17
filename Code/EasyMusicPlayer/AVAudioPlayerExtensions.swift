import AVFoundation

extension AVAudioPlayer {
    var isPaused: Bool {
        !isPlaying && currentTime > 0
    }
}
