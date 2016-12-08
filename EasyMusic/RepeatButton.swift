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
    fileprivate(set) var buttonState: State = State.none
    
    enum State {
        case none
        case one
        case all
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
        case .none:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.RepeatButton), for: .normal)
            break
        case .one:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.RepeatOneButton), for: .normal)
            break
        case .all:
            setBackgroundImage(UIImage.safeImage(named: Constant.Image.RepeatAllButton), for: .normal)
            break
        }
    }
}
