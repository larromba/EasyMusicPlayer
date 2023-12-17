import AVFoundation
import Foundation

/// @mockable
protocol AudioSessionRouteDescription: OutputRouteConvertible {
    var inputs: [AVAudioSessionPortDescription] { get }
    var outputs: [AVAudioSessionPortDescription] { get }
}
extension AVAudioSessionRouteDescription: AudioSessionRouteDescription {
    var outputRoutes: [AVAudioSession.Port] {
        return outputs.map { $0.portType }
    }
}

/// @mockable
protocol AudioSession: OutputRouteConvertible {
    var currentRoute: AVAudioSessionRouteDescription { get }
}
extension AVAudioSession: AudioSession {
    var outputRoutes: [AVAudioSession.Port] {
        return currentRoute.outputs.map { $0.portType }
    }
}

// this complication is necessary for testing, because we can't init AVAudioSessionPortDescription
protocol OutputRouteConvertible {
    var outputRoutes: [AVAudioSession.Port] { get }
}
