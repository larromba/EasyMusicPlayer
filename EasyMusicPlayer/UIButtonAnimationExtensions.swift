import UIKit

extension UIButton {
    func pulse() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        animation.duration = 0.1
        animation.toValue = 1.2
        animation.fromValue = 1.0
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
        layer.add(animation, forKey: "pulseAnimation")
    }

    func spin() {
        let animation = CABasicAnimation(keyPath: "transform.rotation.z")
        animation.duration = 0.2
        animation.toValue = 1.2
        animation.fromValue = .pi * 4.0
        animation.autoreverses = false
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        layer.add(animation, forKey: "spinAnimation")
    }
}
