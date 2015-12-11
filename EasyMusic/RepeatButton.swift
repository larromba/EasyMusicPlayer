//
//  RepeatButton.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

@IBDesignable
class RepeatButton: PlayerButton {
    private(set) var buttonState: State = State.None
    
    enum State {
        case None
        case One
        case All
    }
    
    override func prepareForInterfaceBuilder() {
        setButtonState(buttonState)
    }
    
    // MARK: - internal
    
    func setButtonState(state: State) {
        buttonState = state
        switch state {
        case .None:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.RepeatButton),
                forState: UIControlState.Normal)
            break
        case .One:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.RepeatOneButton),
                forState: UIControlState.Normal)
            break
        case .All:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.RepeatAllButton),
                forState: UIControlState.Normal)
            break
        }
    }
}