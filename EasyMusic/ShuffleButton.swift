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
        self.layer.add(animation, forKey: "spinAnimation")
    }
    
    // MARK: - Private
    
    fileprivate func createSpinAnimation() -> CABasicAnimation {
        let spinAnimation = CABasicAnimation(keyPath: "transform.rotation.z");
        spinAnimation.duration = 0.2;
        spinAnimation.toValue = NSNumber(value: 1.2 as Float);
        spinAnimation.fromValue = NSNumber(value: Float(M_PI * 2.0 * 2) as Float)
        spinAnimation.autoreverses = false
        spinAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut);
        return spinAnimation
    }
}
