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
    fileprivate(set) var buttonState: State = State.play

    enum State {
        case play
        case pause
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setButtonState(buttonState)
    }
    
    override func prepareForInterfaceBuilder() {
        setButtonState(buttonState)
    }
    
    // MARK: - Internal
    
    func setButtonState(_ state: State) {
        buttonState = state
        switch state {
        case .play:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.PlayButton), for: .normal)
            break
        case .pause:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.PauseButton), for: .normal)
            break
        }
    }
}
