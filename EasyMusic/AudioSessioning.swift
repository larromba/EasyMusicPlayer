import AVFoundation
import Foundation
import UIKit

protocol AudioSessioning {
    var outputVolume: Float { get }

    func setCategory_objc(_ category: String, with options: AVAudioSession.CategoryOptions) throws
    func setActive_objc(_ active: Bool) throws
}

extension AVAudioSession: AudioSessioning {
    func setCategory_objc(_ category: String, with options: AVAudioSession.CategoryOptions) throws {
        try setCategory(category, with: options)
    }

    func setActive_objc(_ active: Bool) throws {
        try setActive(active)
    }
}
