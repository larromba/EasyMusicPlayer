import AVFoundation
import Foundation
import Logging

final class ExtendedAudioPlayer: AudioPlayer {
    var isPlaying: Bool {
        return audioPlayer.isPlaying
    }
    var duration: TimeInterval {
        return _duration
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
    private var _duration: TimeInterval
    private var observation: NSKeyValueObservation?
    private let clock = Clock(timeInterval: 1.0)

    init(contentsOf url: URL) throws {
        audioPlayer = try AVAudioPlayer(contentsOf: url)
        _duration = audioPlayer.duration
        clock.setDelegate(self)
    }

    func updateDuration(_ duration: TimeInterval) {
        _duration = duration
    }

    func prepareToPlay() -> Bool {
        return audioPlayer.prepareToPlay()
    }

    func play() -> Bool {
        clock.start()
        return audioPlayer.play()
    }

    func pause() {
        audioPlayer.pause()
        clock.stop()
    }

    func stop() {
        audioPlayer.stop()
        clock.stop()
    }

    // MARK: - private

    private func checkTime(_ time: TimeInterval) {
        if time >= duration {
            delegate?.audioPlayerDidFinishPlaying?(audioPlayer, successfully: true)
        }
    }
}

// MARK: - ClockDelegate

extension ExtendedAudioPlayer: ClockDelegate {
    func clockTicked(_ clock: Clock) {
        checkTime(currentTime)
    }
}
