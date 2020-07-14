import AVFoundation
import Foundation

final class HeadphonesRouteDescription: AVAudioSessionRouteDescription {
    override var outputs: [AVAudioSessionPortDescription] {
        return [HeadphonesPortDescription()]
    }
}
