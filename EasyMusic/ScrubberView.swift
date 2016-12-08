//
//  ScrubberView.swift
//  EasyMusic
//
//  Created by Lee Arromba on 04/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

protocol ScrubberViewDelegate: class {
    func touchMovedToPercentage(_ sender: ScrubberView, percentage: Float)
    func touchEndedAtPercentage(_ sender: ScrubberView, percentage: Float)
}

@IBDesignable
class ScrubberView: UIView {
    @IBOutlet fileprivate weak var trailingEdgeConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var barView: UIView!
    
    fileprivate var scrubberStartDate: Date?
    weak var delegate: ScrubberViewDelegate?
    override var isUserInteractionEnabled: Bool {
        set {
            super.isUserInteractionEnabled = newValue
            
            if newValue == true {
                barView.alpha = 1.0
            } else {
                barView.alpha = 0.5
            }
        }
        get {
            return super.isUserInteractionEnabled
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
        isUserInteractionEnabled = false
       
        // ensure widest screens don't show the scrubber when first appearing
        moveScrubberToPoint(-1000.0)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first != nil {
            scrubberStartDate = Date()
            barView.alpha = 0.65
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.location(in: self)
            moveScrubberToPoint(point.x)
            
            let w = bounds.width
            let perc = Float(point.x / w)
            delegate?.touchMovedToPercentage(self, percentage: perc)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if let scrubberStartDate = scrubberStartDate {
                Analytics.shared.sendTimedAppEvent("scrubber", fromDate: scrubberStartDate, toDate: Date())
            }

            let point = touch.location(in: self)
            let w = bounds.width
            let perc = Float(point.x / w)
            delegate?.touchEndedAtPercentage(self, percentage: perc)
            
            animateTouchesEnded()
        }
    }
    
    // MARK: - Private
    
    fileprivate func moveScrubberToPoint(_ point: CGFloat) {
        let w = bounds.width
        let x = w - point
        trailingEdgeConstraint.constant = x
        layoutIfNeeded()
    }
    
    fileprivate func animateTouchesEnded() {
        UIView.animate(withDuration: 0.15,
            delay: 0.0,
            options: UIViewAnimationOptions.curveEaseIn,
            animations: { () -> Void in
                self.barView.alpha = 1.0
            }, completion: nil)
    }
    
    // MARK: - Internal
    
    func scrubberToPercentage(_ percentage: Float) {
        let w = bounds.width
        let point = w * CGFloat(percentage)
        moveScrubberToPoint(point)
    }
}

// MARK: - Testing

extension ScrubberView {
    var __barView: UIView { return barView }
}
