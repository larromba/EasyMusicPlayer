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
    var playPressedExpectation: XCTestExpectation!
    var stopPressedExpectation: XCTestExpectation!
    var prevPressedExpectation: XCTestExpectation!
    var nextPressedExpectation: XCTestExpectation!
    var shufflePressedExpectation: XCTestExpectation!
    var sharePressedExpectation: XCTestExpectation!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        controlsView = ControlsView()
        controlsView.delegate = self
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsStoppedStateOnInit() {
        controlsView.awakeFromNib()
        
        XCTAssert(controlsView.playButton.enabled == true)
        XCTAssert(controlsView.stopButton.enabled == false)
        XCTAssert(controlsView.prevButton.enabled == false)
        XCTAssert(controlsView.nextButton.enabled == false)
        XCTAssert(controlsView.shuffleButton.enabled == true)
        XCTAssert(controlsView.shareButton.enabled == false)
    }
    
    func testControlsEnabled() {
        let enabled = true
        controlsView.setControlsEnabled(enabled)
        
        XCTAssert(controlsView.playButton.enabled == enabled)
        XCTAssert(controlsView.stopButton.enabled == enabled)
        XCTAssert(controlsView.prevButton.enabled == enabled)
        XCTAssert(controlsView.nextButton.enabled == enabled)
        XCTAssert(controlsView.shuffleButton.enabled == enabled)
        XCTAssert(controlsView.shareButton.enabled == enabled)
    }
    
    func testPlayingState() {
        controlsView.setControlsPlaying()
        
        XCTAssert(controlsView.playButton.enabled == true)
        XCTAssert(controlsView.stopButton.enabled == true)
        XCTAssert(controlsView.prevButton.enabled == true)
        XCTAssert(controlsView.nextButton.enabled == true)
        XCTAssert(controlsView.shuffleButton.enabled == true)
        XCTAssert(controlsView.shareButton.enabled == true)
    }
    
    func testPlayingStateImage() {
        controlsView.setControlsPlaying()
        XCTAssert(controlsView.playButton.buttonState == PlayButtonState.Pause)
    }
    
    func testPauseState() {
        controlsView.setControlsPaused()
        
        XCTAssert(controlsView.playButton.enabled == true)
        XCTAssert(controlsView.stopButton.enabled == true)
        XCTAssert(controlsView.prevButton.enabled == false)
        XCTAssert(controlsView.nextButton.enabled == false)
        XCTAssert(controlsView.shuffleButton.enabled == true)
        XCTAssert(controlsView.shareButton.enabled == false)
    }
    
    func testPauseStateImage() {
        controlsView.setControlsPaused()
        XCTAssert(controlsView.playButton.buttonState == PlayButtonState.Play)
    }
    
    func testStoppedState() {
        controlsView.setControlsStopped()
        
        XCTAssert(controlsView.playButton.enabled == true)
        XCTAssert(controlsView.stopButton.enabled == false)
        XCTAssert(controlsView.prevButton.enabled == false)
        XCTAssert(controlsView.nextButton.enabled == false)
        XCTAssert(controlsView.shuffleButton.enabled == true)
        XCTAssert(controlsView.shareButton.enabled == false)
    }
    
    func testStopStateImage() {
        controlsView.setControlsStopped()
        XCTAssert(controlsView.playButton.buttonState == PlayButtonState.Play)
    }
    
    func testEnablePlay() {
        let enabled = true
        controlsView.enablePlay(enabled)
        XCTAssert(controlsView.playButton.enabled == enabled)
    }
    
    func testEnableRemotePlay() {
        let enabled = true
        controlsView.enablePlay(enabled)
        XCTAssert(MPRemoteCommandCenter.sharedCommandCenter().playCommand.enabled == enabled)
    }
    
    func testEnableStop() {
        let enabled = true
        controlsView.enableStop(enabled)
        XCTAssert(controlsView.stopButton.enabled == enabled)
    }
    
    func testEnableRemoteStop() {
        let enabled = true
        controlsView.enableStop(enabled)
        XCTAssert(MPRemoteCommandCenter.sharedCommandCenter().stopCommand.enabled == enabled)
    }
    
    func testEnablePrevious() {
        let enabled = true
        controlsView.enablePrevious(enabled)
        XCTAssert(controlsView.prevButton.enabled == enabled)
    }
    
    func testEnableRemotePrevious() {
        let enabled = true
        controlsView.enablePrevious(enabled)
        XCTAssert(MPRemoteCommandCenter.sharedCommandCenter().previousTrackCommand.enabled == enabled)
    }
    
    func testEnableNext() {
        let enabled = true
        controlsView.enableNext(enabled)
        XCTAssert(controlsView.nextButton.enabled == enabled)
    }
    
    func testEnableRemoteNext() {
        let enabled = true
        controlsView.enablePlay(enabled)
        XCTAssert(MPRemoteCommandCenter.sharedCommandCenter().nextTrackCommand.enabled == enabled)
    }
    
    func testEnableShuffle() {
        let enabled = true
        controlsView.enableShuffle(enabled)
        XCTAssert(controlsView.shuffleButton.enabled == enabled)
    }
    
    func testEnableShare() {
        let enabled = true
        controlsView.enableShare(enabled)
        XCTAssert(controlsView.shareButton.enabled == enabled)
    }
    
    func testControlsViewDelegatePlayPressed() {
        let mockButton = UIButton()
        playPressedExpectation = expectationWithDescription("ControlsViewDelegate:playPressed")
        controlsView.playButtonPressed(mockButton)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegateStopPressed() {
        let mockButton = UIButton()
        stopPressedExpectation = expectationWithDescription("ControlsViewDelegate:stopPressed")
        controlsView.stopButtonPressed(mockButton)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegatePrevPressed() {
        let mockButton = UIButton()
        prevPressedExpectation = expectationWithDescription("ControlsViewDelegate:prevPressed")
        controlsView.prevButtonPressed(mockButton)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegateNextPressed() {
        let mockButton = UIButton()
        nextPressedExpectation = expectationWithDescription("ControlsViewDelegate:nextPressed")
        controlsView.nextButtonPressed(mockButton)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsViewDelegateShufflePressed() {
        let mockButton = UIButton()
        shufflePressedExpectation = expectationWithDescription("ControlsViewDelegate:shufflePressed")
        controlsView.shuffleButtonPressed(mockButton)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ControlsViewDelegate
extension ControlsViewTests: ControlsViewDelegate {
    func playPressed(sender: ControlsView) {
        playPressedExpectation.fulfill()
    }
    func stopPressed(sender: ControlsView) {
        stopPressedExpectation.fulfill()
    }
    func prevPressed(sender: ControlsView) {
        prevPressedExpectation.fulfill()
    }
    func nextPressed(sender: ControlsView) {
        nextPressedExpectation.fulfill()
    }
    func shufflePressed(sender: ControlsView) {
        shufflePressedExpectation.fulfill()
    }
    func sharePressed(sender: ControlsView) {
        sharePressedExpectation.fulfill()
    }
}