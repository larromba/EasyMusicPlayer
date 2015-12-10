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
    private var controlsView: ControlsView?
    private var controlsExpectation: XCTestExpectation?
    
    override func setUp() {
        super.setUp()
        
        controlsView = ControlsView()
        controlsView!.delegate = self
    }
    
    override func tearDown() {
        super.tearDown()
        
        controlsView = nil
        controlsExpectation = nil
    }
    
    func testIsStoppedStateOnInit() {
        /**
        expectations:
        - controls are in stopped state
        */
        
        // runnable
        controlsView!.awakeFromNib()
        
        // tests
        XCTAssertTrue(controlsView!.playButton.enabled)
        XCTAssertFalse(controlsView!.stopButton.enabled)
        XCTAssertFalse(controlsView!.prevButton.enabled)
        XCTAssertFalse(controlsView!.nextButton.enabled)
        XCTAssertTrue(controlsView!.shuffleButton.enabled)
        XCTAssertFalse(controlsView!.shareButton.enabled)
    }
    
    func testControlsEnabled() {
        /**
         expectations:
         - controls are enabled
         */
        
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.setControlsEnabled(enabled)
        
        // tests
        XCTAssertEqual(controlsView!.playButton.enabled, enabled)
        XCTAssertEqual(controlsView!.stopButton.enabled, enabled)
        XCTAssertEqual(controlsView!.prevButton.enabled, enabled)
        XCTAssertEqual(controlsView!.nextButton.enabled, enabled)
        XCTAssertEqual(controlsView!.shuffleButton.enabled, enabled)
        XCTAssertEqual(controlsView!.shareButton.enabled, enabled)
        XCTAssertEqual(controlsView!.repeatButton.enabled, enabled)
    }
    
    func testPlayingState() {
        /**
        expectations:
        - controls are in playing state
        */
        
        // runnable
        controlsView!.setControlsPlaying()
        
        // tests
        XCTAssertTrue(controlsView!.playButton.enabled)
        XCTAssertTrue(controlsView!.stopButton.enabled)
        XCTAssertTrue(controlsView!.prevButton.enabled)
        XCTAssertTrue(controlsView!.nextButton.enabled)
        XCTAssertTrue(controlsView!.shuffleButton.enabled)
        XCTAssertTrue(controlsView!.shareButton.enabled)
    }
    
    func testPlayingStateImage() {
        /**
        expectations:
        - play button in in play state
        */
        
        // runnable
        controlsView!.setControlsPaused()
        
        // tests
        XCTAssertEqual(controlsView!.playButton.buttonState, PlayButton.State.Play)
    }
    
    func testPausedState() {
        /**
        expectations:
        - controls are in paused state
        */
        
        // runnable
        controlsView!.setControlsPaused()
        
        // tests
        XCTAssertTrue(controlsView!.playButton.enabled)
        XCTAssertTrue(controlsView!.stopButton.enabled)
        XCTAssertFalse(controlsView!.prevButton.enabled)
        XCTAssertFalse(controlsView!.nextButton.enabled)
        XCTAssertTrue(controlsView!.shuffleButton.enabled)
        XCTAssertFalse(controlsView!.shareButton.enabled)
    }
    
    func testPausedStateImage() {
        /**
        expectations:
        - play button shows pause
        */
        
        // runnable
        controlsView!.setControlsPlaying()
        
        // tests
        XCTAssertEqual(controlsView!.playButton.buttonState, PlayButton.State.Pause)
    }
    
    func testStoppedState() {
        /**
        expectations:
        - play button in in stopped state
        */
        
        // runnable
        controlsView!.setControlsStopped()
        
        // tests
        XCTAssertTrue(controlsView!.playButton.enabled)
        XCTAssertFalse(controlsView!.stopButton.enabled)
        XCTAssertFalse(controlsView!.prevButton.enabled)
        XCTAssertFalse(controlsView!.nextButton.enabled)
        XCTAssertTrue(controlsView!.shuffleButton.enabled)
        XCTAssertFalse(controlsView!.shareButton.enabled)
    }
    
    func testStopStateImage() {
        /**
        expectations:
        - play button shows play
        */
        
        // runnable
        controlsView!.setControlsStopped()
        
        // tests
        XCTAssertEqual(controlsView!.playButton.buttonState, PlayButton.State.Play)
    }
    
    func testEnablePlay() {
        /**
         expectations:
         - play button is enabled
         */
        
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enablePlay(enabled)
        
        // tests
        XCTAssertEqual(controlsView!.playButton.enabled, enabled)
    }
    
    func testEnableRemotePlay() {
        /**
         expectations:
         - remote play button is enabled
         */
        
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enablePlay(enabled)
        
        // tests
        XCTAssertEqual(MPRemoteCommandCenter.sharedCommandCenter().playCommand.enabled, enabled)
    }
    
    func testEnableStop() {
        /**
         expectations:
         - stop button is enabled
         */
        
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enableStop(enabled)
        
        // tests
        XCTAssertEqual(controlsView!.stopButton.enabled, enabled)
    }
    
    func testEnableRemoteStop() {
        /**
         expectations:
         - remote stop button is enabled
         */
        
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enableStop(enabled)
        
        // tests
        XCTAssertEqual(MPRemoteCommandCenter.sharedCommandCenter().stopCommand.enabled, enabled)
    }
    
    func testEnablePrevious() {
        /**
         expectations:
         - previous button is enabled
         */
        
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enablePrevious(enabled)
        
        // tests
        XCTAssertEqual(controlsView!.prevButton.enabled, enabled)
    }
    
    func testEnableRemotePrevious() {
        /**
         expectations:
         - remote previous button is enabled
         */
         
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enablePrevious(enabled)
        
        // tests
        XCTAssertEqual(MPRemoteCommandCenter.sharedCommandCenter().previousTrackCommand.enabled, enabled)
    }
    
    func testEnableNext() {
        /**
         expectations:
         - next button is enabled
         */
        
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enableNext(enabled)
        
        // tests
        XCTAssertEqual(controlsView!.nextButton.enabled, enabled)
    }
    
    func testEnableRemoteNext() {
        /**
         expectations:
         - remote next button is enabled
         */
         
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enablePlay(enabled)
        
        // tests
        XCTAssertEqual(MPRemoteCommandCenter.sharedCommandCenter().nextTrackCommand.enabled, enabled)
    }
    
    func testEnableShuffle() {
        /**
         expectations:
         - shuffle button is enabled
         */
        
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enableShuffle(enabled)
        
        // tests
        XCTAssertEqual(controlsView!.shuffleButton.enabled, enabled)
    }
    
    func testEnableShare() {
        /**
         expectations:
         - share button is enabled
         */
         
        // mocks
        let enabled = true
        
        // runnable
        controlsView!.enableShare(enabled)
        
        // tests
        XCTAssertEqual(controlsView!.shareButton.enabled, enabled)
    }
    
    func testEnableRepeat() {
        /**
         expectations:
         - repeat button is enabled
         */
         
         // mocks
        let enabled = true
        
        // runnable
        controlsView!.enableRepeat(enabled)
        
        // tests
        XCTAssertEqual(controlsView!.repeatButton.enabled, enabled)
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
        controlsView!.playButtonPressed(mockButton)
        
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
        controlsView!.stopButtonPressed(mockButton)
        
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
        controlsView!.prevButtonPressed(mockButton)
        
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
        controlsView!.nextButtonPressed(mockButton)
        
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
        controlsView!.shuffleButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegateRepeatPressed() {
        /**
        expectations
        - delegate method called on button press
        */
        controlsExpectation = expectationWithDescription("ControlsViewDelegate.repeatPressed(_)")
        
        // mocks
        let mockButton = UIButton()
        
        // runnable
        controlsView!.repeatButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ControlsViewDelegate
extension ControlsViewTests: ControlsViewDelegate {
    func playPressed(sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }
    
    func stopPressed(sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }
    
    func prevPressed(sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }
    
    func nextPressed(sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }
    
    func shufflePressed(sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }
    
    func sharePressed(sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }
    
    func repeatPressed(sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }
}