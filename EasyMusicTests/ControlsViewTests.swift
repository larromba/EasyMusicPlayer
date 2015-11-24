//
//  ControlsViewTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import MediaPlayer
@testable import EasyMusic

class ControlsViewTests: XCTestCase {
    var controlsView: ControlsView!
    var controlsExpectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        
        controlsView = ControlsView()
        controlsView.delegate = self
    }
    
    func testIsStoppedStateOnInit() {
        // runnable
        controlsView.awakeFromNib()
        
        // tests
        XCTAssert(controlsView.playButton.enabled == true)
        XCTAssert(controlsView.stopButton.enabled == false)
        XCTAssert(controlsView.prevButton.enabled == false)
        XCTAssert(controlsView.nextButton.enabled == false)
        XCTAssert(controlsView.shuffleButton.enabled == true)
        XCTAssert(controlsView.shareButton.enabled == false)
    }
    
    func testControlsEnabled() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.setControlsEnabled(enabled)
        
        // tests
        XCTAssert(controlsView.playButton.enabled == enabled)
        XCTAssert(controlsView.stopButton.enabled == enabled)
        XCTAssert(controlsView.prevButton.enabled == enabled)
        XCTAssert(controlsView.nextButton.enabled == enabled)
        XCTAssert(controlsView.shuffleButton.enabled == enabled)
        XCTAssert(controlsView.shareButton.enabled == enabled)
    }
    
    func testPlayingState() {
        // runnable
        controlsView.setControlsPlaying()
        
        // tests
        XCTAssert(controlsView.playButton.enabled == true)
        XCTAssert(controlsView.stopButton.enabled == true)
        XCTAssert(controlsView.prevButton.enabled == true)
        XCTAssert(controlsView.nextButton.enabled == true)
        XCTAssert(controlsView.shuffleButton.enabled == true)
        XCTAssert(controlsView.shareButton.enabled == true)
    }
    
    func testPlayingStateImage() {
        // runnable
        controlsView.setControlsPlaying()
        
        // tests
        XCTAssert(controlsView.playButton.buttonState == PlayButtonState.Pause)
    }
    
    func testPauseState() {
        // runnable
        controlsView.setControlsPaused()
        
        // tests
        XCTAssert(controlsView.playButton.enabled == true)
        XCTAssert(controlsView.stopButton.enabled == true)
        XCTAssert(controlsView.prevButton.enabled == false)
        XCTAssert(controlsView.nextButton.enabled == false)
        XCTAssert(controlsView.shuffleButton.enabled == true)
        XCTAssert(controlsView.shareButton.enabled == false)
    }
    
    func testPauseStateImage() {
        // runnable
        controlsView.setControlsPaused()
        
        // tests
        XCTAssert(controlsView.playButton.buttonState == PlayButtonState.Play)
    }
    
    func testStoppedState() {
        // runnable
        controlsView.setControlsStopped()
        
        // tests
        XCTAssert(controlsView.playButton.enabled == true)
        XCTAssert(controlsView.stopButton.enabled == false)
        XCTAssert(controlsView.prevButton.enabled == false)
        XCTAssert(controlsView.nextButton.enabled == false)
        XCTAssert(controlsView.shuffleButton.enabled == true)
        XCTAssert(controlsView.shareButton.enabled == false)
    }
    
    func testStopStateImage() {
        // runnable
        controlsView.setControlsStopped()
        
        // tests
        XCTAssert(controlsView.playButton.buttonState == PlayButtonState.Play)
    }
    
    func testEnablePlay() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePlay(enabled)
        
        // tests
        XCTAssert(controlsView.playButton.enabled == enabled)
    }
    
    func testEnableRemotePlay() {
        let enabled = true
        controlsView.enablePlay(enabled)
        XCTAssert(MPRemoteCommandCenter.sharedCommandCenter().playCommand.enabled == enabled)
    }
    
    func testEnableStop() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableStop(enabled)
        
        // tests
        XCTAssert(controlsView.stopButton.enabled == enabled)
    }
    
    func testEnableRemoteStop() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableStop(enabled)
        
        // tests
        XCTAssert(MPRemoteCommandCenter.sharedCommandCenter().stopCommand.enabled == enabled)
    }
    
    func testEnablePrevious() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePrevious(enabled)
        
        // tests
        XCTAssert(controlsView.prevButton.enabled == enabled)
    }
    
    func testEnableRemotePrevious() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePrevious(enabled)
        
        // tests
        XCTAssert(MPRemoteCommandCenter.sharedCommandCenter().previousTrackCommand.enabled == enabled)
    }
    
    func testEnableNext() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableNext(enabled)
        
        // tests
        XCTAssert(controlsView.nextButton.enabled == enabled)
    }
    
    func testEnableRemoteNext() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePlay(enabled)
        
        // tests
        XCTAssert(MPRemoteCommandCenter.sharedCommandCenter().nextTrackCommand.enabled == enabled)
    }
    
    func testEnableShuffle() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableShuffle(enabled)
        
        // tests
        XCTAssert(controlsView.shuffleButton.enabled == enabled)
    }
    
    func testEnableShare() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableShare(enabled)
        
        // tests
        XCTAssert(controlsView.shareButton.enabled == enabled)
    }
    
    func testControlsViewDelegatePlayPressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectationWithDescription("ControlsViewDelegate.playPressed(_)")

        // mocks
        let mockButton = UIButton()
        
        // runnable
        controlsView.playButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegateStopPressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectationWithDescription("ControlsViewDelegate.stopPressed(_)")

        // mocks
        let mockButton = UIButton()
        
        // runnable
        controlsView.stopButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegatePrevPressed() {
        /**
         expectations
         - delegate method called on button press
         */
        let mockButton = UIButton()
        controlsExpectation = expectationWithDescription("ControlsViewDelegate.prevPressed(_)")
        controlsView.prevButtonPressed(mockButton)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegateNextPressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectationWithDescription("ControlsViewDelegate.nextPressed(_)")

        // mocks
        let mockButton = UIButton()
        
        // runnable
        controlsView.nextButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegateShufflePressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectationWithDescription("ControlsViewDelegate.shufflePressed(_)")

        // mocks
        let mockButton = UIButton()
        
        // runnable
        controlsView.shuffleButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ControlsViewDelegate
extension ControlsViewTests: ControlsViewDelegate {
    func playPressed(sender: ControlsView) {
        controlsExpectation.fulfill()
    }
    
    func stopPressed(sender: ControlsView) {
        controlsExpectation.fulfill()
    }
    
    func prevPressed(sender: ControlsView) {
        controlsExpectation.fulfill()
    }
    
    func nextPressed(sender: ControlsView) {
        controlsExpectation.fulfill()
    }
    
    func shufflePressed(sender: ControlsView) {
        controlsExpectation.fulfill()
    }
    
    func sharePressed(sender: ControlsView) {
        controlsExpectation.fulfill()
    }
}