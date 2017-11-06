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
        addTarget(self, action: #selector(touchUpInside), for: UIControlEvents.touchUpInside)
    }
    
    // MARK: - Internal
    
    @objc func touchUpInside() {
        let animation = createPulseAnimation()
        self.layer.add(animation, forKey: "pulseAnimation")
    }
        
    // MARK: - Private
    
    private func createPulseAnimation() -> CABasicAnimation {
        let pulseAnimation = CABasicAnimation(keyPath: "transform.scale");
        pulseAnimation.duration = 0.1;
        pulseAnimation.toValue = 1.2
        pulseAnimation.fromValue = 1.0
        pulseAnimation.autoreverses = true
        pulseAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn);
        return pulseAnimation
    }
}
