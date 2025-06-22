import AVFoundation

/// wrapper around `AVAudioPlayer`
final class AudioPlayerAdaptor: NSObject, AudioPlayer, @unchecked Sendable {
    var isPlaying: Bool { audioPlayer.isPlaying }
    var isPaused: Bool { audioPlayer.isPaused }
    var currentTime: TimeInterval {
        get { audioPlayer.currentTime }
        set { audioPlayer.currentTime = newValue }
    }
    var duration: TimeInterval { audioPlayer.duration }
    var volume: Float { audioPlayer.volume }
    var isLofiEnabled: Bool { false }
    var isDistortionEnabled: Bool { false }
    var delegate: AudioPlayerDelegate?

    private let audioPlayer: AVAudioPlayer

    @available(*, deprecated, message: "Use AudioEngineAdaptor(url:) instead")
    init(contentsOf url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
    }

    func play() -> Bool {
        audioPlayer.play()
    }

    func pause() {
        audioPlayer.pause()
    }

    func stop() {
        audioPlayer.stop()
    }

    func prepareToPlay() -> Bool {
        audioPlayer.prepareToPlay()
    }

    func setLoFiEnabled(_ isEnabled: Bool) {
        logWarning("lofi not available with AVAudioPlayer")
    }

    func setDistortionEnabled(_ isEnabled: Bool) {
        logWarning("distortion not available with AVAudioPlayer")
    }
}

extension AudioPlayerAdaptor: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.audioPlayerDidFinishPlaying(self, successfully: flag)
    }

    func audioPlayerDecodeErrorDidOccur(_ service: AVAudioPlayer, error: Error?) {
        delegate?.audioPlayerDecodeErrorDidOccur(self, error: error)
    }
}
