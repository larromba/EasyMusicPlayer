//
//  PlayButton.swift
//  EasyMusic
//
//  Created by Lee Arromba on 14/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

enum PlayButtonState {
    case Play
    case Pause
}

@IBDesignable
class PlayButton: UIButton {
    private(set) var buttonState: PlayButtonState!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        buttonState = PlayButtonState.Play
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        buttonState = PlayButtonState.Play
    }
    
    override func prepareForInterfaceBuilder() {
        buttonState = PlayButtonState.Play
    }
    
    // MARK: - Public
    
    func setButtonState(state: PlayButtonState) {
        buttonState = state
        switch state {
        case .Play:
            setBackgroundImage(UIImage.safeImage(named: "PlayButton"),
                forState: UIControlState.Normal)
            break
        case .Pause:
            setBackgroundImage(UIImage.safeImage(named: "PauseButton"),
                forState: UIControlState.Normal)
            break
        }
    }
}