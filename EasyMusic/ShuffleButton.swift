//
//  ShuffleButton.swift
//  EasyMusic
//
//  Created by Lee Arromba on 16/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

class ShuffleButton: PlayerButton {
    override func touchUpInside() {
        super.touchUpInside()
        
        let animation = createSpinAnimation()
        self.layer.addAnimation(animation, forKey: "spinAnimation")
    }
    
    // MARK: - Private
    
    private func createSpinAnimation() -> CABasicAnimation {
        let spinAnimation = CABasicAnimation(keyPath: "transform.rotation.z");
        spinAnimation.duration = 0.2;
        spinAnimation.toValue = NSNumber(float: 1.2);
        spinAnimation.fromValue = NSNumber(float: Float(M_PI * 2.0 * 2))
        spinAnimation.autoreverses = false
        spinAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut);
        return spinAnimation
    }
}