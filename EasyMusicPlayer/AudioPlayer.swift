import AVFoundation
import Foundation
import Logging

// sourcery: name = AudioPlayer
protocol AudioPlayer: Mockable {
    var isPlaying: Bool { get }
    var duration: TimeInterval { get }
    var delegate: AVAudioPlayerDelegate? { get set }
    var currentTime: TimeInterval { get set }
    var url: URL? { get }

    func prepareToPlay() -> Bool
    func play() -> Bool
    func pause()
    func stop()

    init(contentsOf url: URL) throws

    func updateDuration(_ duration: TimeInterval)
}
extension AVAudioPlayer: AudioPlayer {
    func updateDuration(_ duration: TimeInterval) {
        logWarning("updateDuration(_:) not overridden")
    }
}
