import AVFoundation
import Foundation

// sourcery: name = AudioPlayer
protocol AudioPlayer: AnyObject, Mockable {
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
}
extension AVAudioPlayer: AudioPlayer {}
