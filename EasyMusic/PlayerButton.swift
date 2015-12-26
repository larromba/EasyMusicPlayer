//
//  PlayerButton.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

class PlayerButton: UIButton {
    override func awakeFromNib() {
        addTarget(self, action: safeSelector("touchUpInside"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    // MARK: - Internal
    
    func touchUpInside() {
        let animation = createPulseAnimation()
        self.layer.addAnimation(animation, forKey: "pulseAnimation")
    }
        
    // MARK: - Private
    
    private func createPulseAnimation() -> CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale");
        pulseAnimation.duration = 0.1;
        pulseAnimation.toValue = NSNumber(float: 1.2);
        pulseAnimation.fromValue = NSNumber(float: 1.0)
        pulseAnimation.autoreverses = true
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        return pulseAnimation
    }
}