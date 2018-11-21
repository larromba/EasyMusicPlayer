import UIKit

// TODO: this
//class QueueAnimation: NSObject, UIViewControllerAnimatedTransitioning {
//    weak var controls: ControlsView?
//    weak var topConstraint: NSLayoutConstraint?
//
//    init(controls: ControlsView, topConstraint: NSLayoutConstraint) {
//        self.controls = controls
//        self.topConstraint = topConstraint
//        super.init()
//    }
//
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 5.0
//    }
//
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        controls?.playButton.layer.add(createPulseAnimation(), forKey: "pulseAnimation")
//        controls?.stopButton.layer.add(createPulseAnimation(), forKey: "pulseAnimation")
//        controls?.prevButton.layer.add(createPulseAnimation(), forKey: "pulseAnimation")
//        controls?.nextButton.layer.add(createPulseAnimation(), forKey: "pulseAnimation")
//        controls?.shuffleButton.layer.add(createPulseAnimation(), forKey: "pulseAnimation")
//        controls?.shareButton.layer.add(createPulseAnimation(), forKey: "pulseAnimation")
//        controls?.repeatButton.layer.add(createPulseAnimation(), forKey: "pulseAnimation")
//
//        let view = transitionContext.view(forKey: .from)!
//
//        topConstraint?.constant = -1000
//        UIView.animate(withDuration: 1.0, delay: 0.5, options: .curveEaseIn, animations: {
//            view.layoutIfNeeded()
//        }, completion: nil)
//    }
//
//    private func createPulseAnimation() -> CABasicAnimation {
//        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale");
//        pulseAnimation.duration = 0.5 // TODO
//        pulseAnimation.toValue = 0.0
//        pulseAnimation.fromValue = 1.0
//        pulseAnimation.autoreverses = false
//        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
//        pulseAnimation.fillMode = kCAFillModeForwards
//        pulseAnimation.isRemovedOnCompletion = false
//        return pulseAnimation
//    }
//}
