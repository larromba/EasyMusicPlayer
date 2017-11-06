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
        playButton = nil
        
        super.tearDown()
    }
    
    func testPlayButtonState() {
        /**
         expectations
         - button state is correct
         */
        
        // mocks
        let expected = PlayButton.State.pause
        
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
        playButton!.setBackgroundImage(nil, for: UIControlState.normal)
        
        // runnable
        playButton!.setButtonState(PlayButton.State.pause)
      
        // tests
        XCTAssertNotNil(playButton!.backgroundImage(for: UIControlState.normal))
    }
}
