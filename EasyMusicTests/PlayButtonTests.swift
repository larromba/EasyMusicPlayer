//
//  PlayButtonTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest

@testable import EasyMusic

class PlayButtonTests: XCTestCase {
    var playButton: PlayButton!
    
    override func setUp() {
        super.setUp()
        
        playButton = PlayButton()
    }
    
    func testPlayButtonState() {
        // mocks
        let expected = PlayButtonState.Pause
        
        // runnable
        playButton.setButtonState(expected)
        
        // tests
        XCTAssertEqual(playButton.buttonState, expected)
    }
    
    func testPlayButtonImage() {
        // mocks
        let mockButton = PlayButton()
        mockButton.setBackgroundImage(nil, forState: UIControlState.Normal)
        
        // runnable
        mockButton.setButtonState(PlayButtonState.Pause)
      
        // tests
        XCTAssertNotNil(mockButton.backgroundImageForState(UIControlState.Normal))
    }
}