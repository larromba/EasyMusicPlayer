import UIKit

struct MusicPlayerButton {
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
