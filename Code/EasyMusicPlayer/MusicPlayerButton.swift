import UIKit

protocol MusicPlayerControl {
    var image: UIImage { get set }
    var accessibilityLabel: String { get set }
    var isDisabled: Bool { get set }
    var rotation: Double { get set }
    var maxRotation: Double { get set }
    var scale: Double { get set }
    var maxScale: Double { get set }
    var opacity: Double { get }

    mutating func reset()
    mutating func animate()
}

struct MusicPlayerButton: MusicPlayerControl {
    var image: UIImage
    var accessibilityLabel: String
    var isDisabled: Bool
    var rotation = 0.0
    var maxRotation = 0.0
    var scale = 1.0
    var maxScale = 1.3
    var opacity: Double {
        isDisabled ? 0.5 : 1.0
    }

    mutating func reset() {
        rotation = 0
        scale = 1
    }

    mutating func animate() {
        rotation = maxRotation
        scale = maxScale
    }
}

struct MusicPlayerFXButton: MusicPlayerControl {
    var image: UIImage
    var accessibilityLabel: String
    var isDisabled = false
    var isFXEnabled: Bool
    var rotation = 0.0
    var maxRotation = 0.0
    var scale = 1.0
    var maxScale = 1.3
    var opacity: Double {
        isFXEnabled ? 1.0 : 0.5
    }

    mutating func reset() {
        rotation = 0
        scale = 1
    }

    mutating func animate() {
        rotation = maxRotation
        scale = maxScale
    }
}
