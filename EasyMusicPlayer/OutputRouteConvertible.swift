import AVFoundation
import Foundation

protocol OutputRouteConvertible {
    var outputRoutes: [AVAudioSession.Port] { get }
}
