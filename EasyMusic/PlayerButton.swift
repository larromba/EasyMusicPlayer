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
        addTarget(self, action: safeSelector("touchUpInside"), for: UIControlEvents.touchUpInside)
    }
    
    // MARK: - Internal
    
    func touchUpInside() {
        let animation = createPulseAnimation()
        self.layer.add(animation, forKey: "pulseAnimation")
    }
        
    // MARK: - Private
    
    fileprivate func createPulseAnimation() -> CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale");
        pulseAnimation.duration = 0.1;
        pulseAnimation.toValue = NSNumber(value: 1.2 as Float);
        pulseAnimation.fromValue = NSNumber(value: 1.0 as Float)
        pulseAnimation.autoreverses = true
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        return pulseAnimation
    }
}
