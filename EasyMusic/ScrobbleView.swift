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
    @IBOutlet private(set) weak var barView: UIView!
    
    var delegate: ScrobbleViewDelegate?
    var enabled: Bool = false
    
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
        guard enabled == true else {
            return
        }

        if let touch = touches.first {
            let point = touch.locationInView(self)
            moveScrobblerToPoint(point.x)
            
            let w = CGRectGetWidth(bounds)
            let perc = Float(point.x / w)
            delegate?.touchMovedToPercentage(self, percentage: perc)
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        guard enabled == true else {
            return
        }
        
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