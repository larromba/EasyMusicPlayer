import AVFoundation

protocol Effect: AnyObject {
    var isEnabled: Bool { get set }
    var lastNode: AVAudioNode { get }

    func attach(to engine: AVAudioEngine)
    func connect(engine: AVAudioEngine, to audioUnit: AVAudioNode, format: AVAudioFormat?)
}
