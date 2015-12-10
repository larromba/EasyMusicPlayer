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
    private var playButton: PlayButton?
    
    override func setUp() {
        super.setUp()
        
        playButton = PlayButton()
    }
    
    override func tearDown() {
        super.tearDown()
        
        playButton = nil
    }
    
    func testPlayButtonState() {
        /**
         expectations
         - button state is correct
         */
        
        // mocks
        let expected = PlayButtonState.Pause
        
        // runnable
        playButton!.setButtonState(expected)
        
        // tests
        XCTAssertEqual(playButton!.buttonState, expected)
    }
    
    func testPlayButtonImage() {
        /**
         expectations
         - background image changes 
         */
        
        // mocks
        playButton!.setBackgroundImage(nil, forState: UIControlState.Normal)
        
        // runnable
        playButton!.setButtonState(PlayButtonState.Pause)
      
        // tests
        XCTAssertNotNil(playButton!.backgroundImageForState(UIControlState.Normal))
    }
}