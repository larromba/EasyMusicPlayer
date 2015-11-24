//
//  PlayButtonTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest

@testable import EasyMusic

private var buttonExpectation: XCTestExpectation!

class PlayButtonTests: XCTestCase {
    var playButton: PlayButton!
    
    override func setUp() {
        super.setUp()
        
        playButton = PlayButton()
    }
    
    func testPlayButtonState() {
        // runnable
        playButton.setButtonState(PlayButtonState.Pause)
        
        // tests
        XCTAssert(playButton.buttonState == PlayButtonState.Pause)
    }
    
    func testPlayButtonImage() {
        /**
        expectations
        - button background image changes on button state change
        */
        buttonExpectation = expectationWithDescription("button.setBackgroundImage(_, _)")
        
        // mocks
        class MockPlayButton: PlayButton {
            override func setBackgroundImage(image: UIImage?, forState state: UIControlState) {
                buttonExpectation.fulfill()
            }
        }
        
        let mockButton = MockPlayButton()
        
        // runnable
        mockButton.setButtonState(PlayButtonState.Pause)
      
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}