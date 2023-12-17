import AVFoundation

/// @mockable
protocol SoundEffecting {
    func play(_ sound: SoundEffect)
}

enum SoundEffect: String {
    case finished
    case error
    case toggle
    case casette
    case play
    case stop
    case prev
    case next
    case shuffle
    case `repeat`
    case search

    var ext: String {
        switch self {
        case .toggle: return "mp3"
        default: return "aif"
        }
    }
}

final class SoundEffects: NSObject, SoundEffecting {
    private let session: AVAudioSession
    private var audioPlayer: AVAudioPlayer?

    init(session: AVAudioSession = .sharedInstance()) {
        self.session = session
    }

    func play(_ sound: SoundEffect) {
        play(Bundle.safeMain.url(forResource: sound.rawValue, withExtension: sound.ext)!)
    }

    private func play(_ url: URL) {
        do {
            let audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer.delegate = self
            self.audioPlayer = audioPlayer
            try session.setCategory(.playback)
            try session.setActive(true)
            audioPlayer.play()
        } catch {
            logError("sound effect issue: \(error)")
        }
    }
}

extension SoundEffects: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ service: AVAudioPlayer, successfully flag: Bool) {
        if !flag { logError("issue finishing sound effect") }
        self.audioPlayer = nil
    }

    func audioPlayerDecodeErrorDidOccur(_ service: AVAudioPlayer, error: Error?) {
        logError("sound effects decode error: \(String(describing: error))")
        self.audioPlayer = nil
    }
}
