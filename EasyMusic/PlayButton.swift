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

    override func awakeFromNib() {
        setButtonState(PlayButtonState.Play)
    }
    
    override func prepareForInterfaceBuilder() {
        setButtonState(PlayButtonState.Play)
    }
    
    // MARK: - internal
    
    func setButtonState(state: PlayButtonState) {
        buttonState = state
        switch state {
        case .Play:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.PlayButton),
                forState: UIControlState.Normal)
            break
        case .Pause:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.PauseButton),
                forState: UIControlState.Normal)
            break
        }
    }
}