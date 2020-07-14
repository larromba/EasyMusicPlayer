import AVFoundation
import Foundation

final class HeadphonesPortDescription: AVAudioSessionPortDescription {
    override var portName: String {
        return AVAudioSession.Port.headphones.rawValue
    }
}
