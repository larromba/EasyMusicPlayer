import Foundation

protocol AudioPlayer {
    var isPlaying: Bool { get }
    var isPaused: Bool { get }
    var currentTime: TimeInterval { get set }
    var duration: TimeInterval { get }
    var volume: Float { get }
    var isLofiEnabled: Bool { get }
    var isDistortionEnabled: Bool { get }
    var delegate: AudioPlayerDelegate? { get set }

    init(contentsOf url: URL) throws

    func play() -> Bool
    func pause()
    func stop()
    func prepareToPlay() -> Bool
    func setLoFiEnabled(_ isEnabled: Bool)
    func setDistortionEnabled(_ isEnabled: Bool)
}

protocol AudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AudioPlayer, successfully flag: Bool)
    func audioPlayerDecodeErrorDidOccur(_ player: AudioPlayer, error: Error?)
}
