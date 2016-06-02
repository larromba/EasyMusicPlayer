//
//  SeekButton.swift
//  EasyMusic
//
//  Created by Lee Arromba on 25/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

class SeekButton: PlayerButton {
    typealias SeekAction = (Seek -> Void)

    enum Seek {
        case Start
        case End
    }
    
    private var longPressRecogniser: UILongPressGestureRecognizer!
    private var seekAction: SeekAction?
    private var longPressTimer: NSTimer?
    private(set) var isSeeking: Bool = false
    var isTouchUpInsideEnabled: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addTarget(self, action: safeSelector("touchDown"), forControlEvents: UIControlEvents.TouchDown)
    }
    
    // MARK: - Internal

    func setSeekAction(seekAction: SeekAction) {
        self.seekAction = seekAction
    }
    
    override func touchUpInside() {
        stopLongPressTimer()
        
        if isSeeking == true {
            if let seekAction = seekAction {
                seekAction(Seek.End)
            }
            isSeeking = false
            return
        }
        
        if isTouchUpInsideEnabled == true {
            super.touchUpInside()
        }
    }
    
    func touchDown() {
        if longPressTimer != nil {
            stopLongPressTimer()
        }
        
        longPressTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: safeSelector("longPressAction"),
            userInfo: nil,
            repeats: false)
    }
    
    func longPressAction() {
        if let seekAction = seekAction {
            seekAction(Seek.Start)
            isSeeking = true
        }
    }
    
    // MARK: - Private
    
    func stopLongPressTimer() {
        longPressTimer?.invalidate()
        longPressTimer = nil
    }
}

// MARK: - Testing

extension SeekButton {
    var __seekAction: SeekAction? {
        set { seekAction = newValue }
        get { return seekAction }
    }
}