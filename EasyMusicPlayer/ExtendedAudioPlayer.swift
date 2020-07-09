import AVFoundation
import Foundation
import Logging

final class ExtendedAudioPlayer: AudioPlayer {
    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }
    var duration: TimeInterval {
        guard let analysisInformation = analysisInformation else { return audioPlayer.duration }
        // silence is music too, but end silences longer than 5 seconds are painful, so shorten duration
        if analysisInformation.durationOfEndSilence > 5 {
            return analysisInformation.durationWithoutEndSilence
        } else {
            return analysisInformation.duration
        }
    }
    var delegate: AVAudioPlayerDelegate? {
        get { return audioPlayer.delegate }
        set { audioPlayer.delegate = newValue }
    }
    var currentTime: TimeInterval {
        get { return audioPlayer.currentTime }
        set { audioPlayer.currentTime = newValue }
    }
    var url: URL? {
        return audioPlayer.url
    }

    private let audioPlayer: AVAudioPlayer
    private var analysisInformation: AudioAnalysisInformation?

    init(contentsOf url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)

        // AudioAnalysisInformation is quite time consuming, so done on background so doesn't block main thread.
        // [weak self] so audioPlayer is released without waiting.
        // this is better for memory when quickly skipping big files
        DispatchQueue.main.async { [weak self] in
            do {
                self?.analysisInformation = try AudioAnalysisInformation(contentsOf: url)
            } catch {
                logError(error.localizedDescription)
            }
        }
    }

    func prepareToPlay() -> Bool {
        audioPlayer.prepareToPlay()
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
}
