//
//  ScrubberView.swift
//  EasyMusic
//
//  Created by Lee Arromba on 04/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

protocol ScrubberViewDelegate: class {
    func touchMovedToPercentage(sender: ScrubberView, percentage: Float)
    func touchEndedAtPercentage(sender: ScrubberView, percentage: Float)
}

@IBDesignable
class ScrubberView: UIView {
    @IBOutlet private weak var trailingEdgeConstraint: NSLayoutConstraint!
    @IBOutlet private weak var barView: UIView!
    
    private var scrubberStartDate: NSDate?
    weak var delegate: ScrubberViewDelegate?
    override var userInteractionEnabled: Bool {
        set {
            super.userInteractionEnabled = newValue
            
            if newValue == true {
                barView.alpha = 1.0
            } else {
                barView.alpha = 0.5
            }
        }
        get {
            return super.userInteractionEnabled
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override func awakeFromNib() {
        userInteractionEnabled = false
       
        // ensure widest screens don't show the scrubber when first appearing
        moveScrubberToPoint(-1000.0)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if touches.first != nil {
            scrubberStartDate = NSDate()
            barView.alpha = 0.65
        }
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            moveScrubberToPoint(point.x)
            
            let w = CGRectGetWidth(bounds)
            let perc = Float(point.x / w)
            delegate?.touchMovedToPercentage(self, percentage: perc)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            if let scrubberStartDate = scrubberStartDate {
                Analytics.shared.sendTimedAppEvent("scrubber", fromDate: scrubberStartDate, toDate: NSDate())
            }

            let point = touch.locationInView(self)
            let w = CGRectGetWidth(bounds)
            let perc = Float(point.x / w)
            delegate?.touchEndedAtPercentage(self, percentage: perc)
            
            animateTouchesEnded()
        }
    }
    
    // MARK: - Private
    
    private func moveScrubberToPoint(point: CGFloat) {
        let w = CGRectGetWidth(bounds)
        let x = w - point
        trailingEdgeConstraint.constant = x
        layoutIfNeeded()
    }
    
    private func animateTouchesEnded() {
        UIView.animateWithDuration(0.15,
            delay: 0.0,
            options: UIViewAnimationOptions.CurveEaseIn,
            animations: { () -> Void in
                self.barView.alpha = 1.0
            }, completion: nil)
    }
    
    // MARK: - Internal
    
    func scrubberToPercentage(percentage: Float) {
        let w = CGRectGetWidth(bounds)
        let point = w * CGFloat(percentage)
        moveScrubberToPoint(point)
    }
}

// MARK: - Testing

extension ScrubberView {
    var __barView: UIView { return barView }
}