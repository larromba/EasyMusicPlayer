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
        XCTAssertTrue(controlsView.playButton.enabled)
        XCTAssertFalse(controlsView.stopButton.enabled)
        XCTAssertFalse(controlsView.prevButton.enabled)
        XCTAssertFalse(controlsView.nextButton.enabled)
        XCTAssertTrue(controlsView.shuffleButton.enabled)
        XCTAssertFalse(controlsView.shareButton.enabled)
    }
    
    func testControlsEnabled() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.setControlsEnabled(enabled)
        
        // tests
        XCTAssertEqual(controlsView.playButton.enabled, enabled)
        XCTAssertEqual(controlsView.stopButton.enabled, enabled)
        XCTAssertEqual(controlsView.prevButton.enabled, enabled)
        XCTAssertEqual(controlsView.nextButton.enabled, enabled)
        XCTAssertEqual(controlsView.shuffleButton.enabled, enabled)
        XCTAssertEqual(controlsView.shareButton.enabled, enabled)
    }
    
    func testPlayingState() {
        // runnable
        controlsView.setControlsPlaying()
        
        // tests
        XCTAssertTrue(controlsView.playButton.enabled)
        XCTAssertTrue(controlsView.stopButton.enabled)
        XCTAssertTrue(controlsView.prevButton.enabled)
        XCTAssertTrue(controlsView.nextButton.enabled)
        XCTAssertTrue(controlsView.shuffleButton.enabled)
        XCTAssertTrue(controlsView.shareButton.enabled)
    }
    
    func testPlayingStateImage() {
        // runnable
        controlsView.setControlsPlaying()
        
        // tests
        XCTAssertEqual(controlsView.playButton.buttonState, PlayButtonState.Pause)
    }
    
    func testPauseState() {
        // runnable
        controlsView.setControlsPaused()
        
        // tests
        XCTAssertTrue(controlsView.playButton.enabled)
        XCTAssertTrue(controlsView.stopButton.enabled)
        XCTAssertFalse(controlsView.prevButton.enabled)
        XCTAssertFalse(controlsView.nextButton.enabled)
        XCTAssertTrue(controlsView.shuffleButton.enabled)
        XCTAssertFalse(controlsView.shareButton.enabled)
    }
    
    func testPauseStateImage() {
        // runnable
        controlsView.setControlsPaused()
        
        // tests
        XCTAssertEqual(controlsView.playButton.buttonState, PlayButtonState.Play)
    }
    
    func testStoppedState() {
        // runnable
        controlsView.setControlsStopped()
        
        // tests
        XCTAssertTrue(controlsView.playButton.enabled)
        XCTAssertFalse(controlsView.stopButton.enabled)
        XCTAssertFalse(controlsView.prevButton.enabled)
        XCTAssertFalse(controlsView.nextButton.enabled)
        XCTAssertTrue(controlsView.shuffleButton.enabled)
        XCTAssertFalse(controlsView.shareButton.enabled)
    }
    
    func testStopStateImage() {
        // runnable
        controlsView.setControlsStopped()
        
        // tests
        XCTAssertEqual(controlsView.playButton.buttonState, PlayButtonState.Play)
    }
    
    func testEnablePlay() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePlay(enabled)
        
        // tests
        XCTAssertEqual(controlsView.playButton.enabled, enabled)
    }
    
    func testEnableRemotePlay() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePlay(enabled)
        
        // tests
        XCTAssertEqual(MPRemoteCommandCenter.sharedCommandCenter().playCommand.enabled, enabled)
    }
    
    func testEnableStop() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableStop(enabled)
        
        // tests
        XCTAssertEqual(controlsView.stopButton.enabled, enabled)
    }
    
    func testEnableRemoteStop() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableStop(enabled)
        
        // tests
        XCTAssertEqual(MPRemoteCommandCenter.sharedCommandCenter().stopCommand.enabled, enabled)
    }
    
    func testEnablePrevious() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePrevious(enabled)
        
        // tests
        XCTAssertEqual(controlsView.prevButton.enabled, enabled)
    }
    
    func testEnableRemotePrevious() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePrevious(enabled)
        
        // tests
        XCTAssertEqual(MPRemoteCommandCenter.sharedCommandCenter().previousTrackCommand.enabled, enabled)
    }
    
    func testEnableNext() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableNext(enabled)
        
        // tests
        XCTAssertEqual(controlsView.nextButton.enabled, enabled)
    }
    
    func testEnableRemoteNext() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enablePlay(enabled)
        
        // tests
        XCTAssertEqual(MPRemoteCommandCenter.sharedCommandCenter().nextTrackCommand.enabled, enabled)
    }
    
    func testEnableShuffle() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableShuffle(enabled)
        
        // tests
        XCTAssertEqual(controlsView.shuffleButton.enabled, enabled)
    }
    
    func testEnableShare() {
        // mocks
        let enabled = true
        
        // runnable
        controlsView.enableShare(enabled)
        
        // tests
        XCTAssertEqual(controlsView.shareButton.enabled, enabled)
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
        controlsExpectation = expectationWithDescription("ControlsViewDelegate.prevPressed(_)")

        // mocks
        let mockButton = UIButton()
        
        // runnable
        controlsView.prevButtonPressed(mockButton)
        
        // tests
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