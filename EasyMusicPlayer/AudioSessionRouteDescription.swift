import AVFoundation
import Foundation

// sourcery: name = AudioSessionRouteDescription
protocol AudioSessionRouteDescription: Mockable {
    var outputRoutes: [AVAudioSession.Port] { get }
}
extension AVAudioSessionRouteDescription: AudioSessionRouteDescription {
    var outputRoutes: [AVAudioSession.Port] {
        return outputs.map { $0.portType }
    }
}
