import AVFoundation
import Foundation
import UIKit

// sourcery: name = AudioSession
protocol AudioSession: Mockable {
    // sourcery: value = 1.0
    var outputVolume: Float { get }
    var outputRoutes: [AVAudioSession.Port] { get }

    func setCategory_objc(_ category: AVAudioSession.Category, with options: AVAudioSession.CategoryOptions) throws
    func setActive_objc(_ active: Bool, options: AVAudioSession.SetActiveOptions) throws
}

extension AVAudioSession: AudioSession {
    var outputRoutes: [AVAudioSession.Port] {
        return currentRoute.outputs.map { $0.portType }
    }

    func setCategory_objc(_ category: AVAudioSession.Category, with options: AVAudioSession.CategoryOptions) throws {
        try setCategory(category, options: options)
    }

    func setActive_objc(_ active: Bool, options: AVAudioSession.SetActiveOptions = []) throws {
        try setActive(active, options: options)
    }
}
