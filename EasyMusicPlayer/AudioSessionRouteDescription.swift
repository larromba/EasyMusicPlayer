import AVFoundation
import Foundation

// sourcery: name = AudioSessionRouteDescription
protocol AudioSessionRouteDescription: OutputRouteConvertible, Mockable {
    // 🦄
}
extension AVAudioSessionRouteDescription: AudioSessionRouteDescription {
    var outputRoutes: [AVAudioSession.Port] {
        return outputs.map { $0.portType }
    }
}
