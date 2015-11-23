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
        playButton.setButtonState(PlayButtonState.Pause)
        XCTAssert(playButton.buttonState == PlayButtonState.Pause)
    }
    
    func testPlayButtonImage() {
        /**
        expectations
        - button background image changes on button state change
        */
        buttonExpectation = expectationWithDescription("button.setBackgroundImage(_, _)")
        
        class MockPlayButton: PlayButton {
            override func setBackgroundImage(image: UIImage?, forState state: UIControlState) {
                buttonExpectation.fulfill()
            }
        }
        
        let mockButton = MockPlayButton()
        mockButton.setButtonState(PlayButtonState.Pause)
      
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}