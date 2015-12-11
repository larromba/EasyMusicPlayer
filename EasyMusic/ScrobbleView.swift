//
//  ScrobbleView.swift
//  EasyMusic
//
//  Created by Lee Arromba on 04/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

protocol ScrobbleViewDelegate {
    func touchMovedToPercentage(sender: ScrobbleView, percentage: Float)
    func touchEndedAtPercentage(sender: ScrobbleView, percentage: Float)
}

@IBDesignable
class ScrobbleView: UIView {
    @IBOutlet private weak var trailingEdgeConstraint: NSLayoutConstraint!
    @IBOutlet private weak var barView: UIView!
    
    var delegate: ScrobbleViewDelegate?
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
        moveScrobblerToPoint(0.0)
    }

    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            moveScrobblerToPoint(point.x)
            
            let w = CGRectGetWidth(bounds)
            let perc = Float(point.x / w)
            delegate?.touchMovedToPercentage(self, percentage: perc)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touch = touches.first {
            let point = touch.locationInView(self)
            let w = CGRectGetWidth(bounds)
            let perc = Float(point.x / w)
            delegate?.touchEndedAtPercentage(self, percentage: perc)
        }
    }
    
    // MARK: - private
    
    private func moveScrobblerToPoint(point: CGFloat) {
        let w = CGRectGetWidth(bounds)
        let x = w - point
        trailingEdgeConstraint.constant = x
        layoutIfNeeded()
    }
    
    // MARK: - internal
    
    func scrobbleToPercentage(percentage: Float) {
        let w = CGRectGetWidth(bounds)
        let point = w * CGFloat(percentage)
        moveScrobblerToPoint(point)
    }
}

// MARK: - Testing

extension ScrobbleView {
    var __barView: UIView { return barView }
}