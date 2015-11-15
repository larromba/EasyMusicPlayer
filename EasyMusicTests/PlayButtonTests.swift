//
//  PlayButtonTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest

@testable import EasyMusic

var imageExpectation: XCTestExpectation!

class MockPlayButton: PlayButton {
    override func setBackgroundImage(image: UIImage?, forState state: UIControlState) {
        imageExpectation.fulfill()
    }
}

class PlayButtonTests: XCTestCase {
    var playButton: PlayButton!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        playButton = PlayButton()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlayButtonState() {
        playButton.setButtonState(PlayButtonState.Pause)
        XCTAssert(playButton.buttonState == PlayButtonState.Pause)
    }
    
    func testPlayButtonImage() {
        imageExpectation = expectationWithDescription("ControlsViewDelegate:stopPressed")
        
        let mockButton = MockPlayButton()
        mockButton.setButtonState(PlayButtonState.Pause)
      
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}