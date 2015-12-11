//
//  PlayButton.swift
//  EasyMusic
//
//  Created by Lee Arromba on 14/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

@IBDesignable
class PlayButton: PlayerButton {
    private(set) var buttonState: State = State.Play

    enum State {
        case Play
        case Pause
    }
    
    override func prepareForInterfaceBuilder() {
        setButtonState(buttonState)
    }
    
    // MARK: - internal
    
    func setButtonState(state: State) {
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