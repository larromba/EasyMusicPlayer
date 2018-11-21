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
        controlsView = nil
        controlsExpectation = nil

        super.tearDown()
    }

    func testIsStoppedStateOnInit() {
        /**
        expectations:
        - controls are in stopped state
        */

        // runnable
        controlsView!.awakeFromNib()

        // tests
        XCTAssertTrue(controlsView!.playButton.isEnabled)
        XCTAssertFalse(controlsView!.stopButton.isEnabled)
        XCTAssertFalse(controlsView!.prevButton.isEnabled)
        XCTAssertFalse(controlsView!.nextButton.isEnabled)
        XCTAssertTrue(controlsView!.shuffleButton.isEnabled)
        XCTAssertFalse(controlsView!.shareButton.isEnabled)
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
        XCTAssertEqual(controlsView!.playButton.isEnabled, enabled)
        XCTAssertEqual(controlsView!.stopButton.isEnabled, enabled)
        XCTAssertEqual(controlsView!.prevButton.isEnabled, enabled)
        XCTAssertEqual(controlsView!.nextButton.isEnabled, enabled)
        XCTAssertEqual(controlsView!.shuffleButton.isEnabled, enabled)
        XCTAssertEqual(controlsView!.shareButton.isEnabled, enabled)
        XCTAssertEqual(controlsView!.repeatButton.isEnabled, enabled)
    }

    func testPlayingState() {
        /**
        expectations:
        - controls are in playing state
        */

        // runnable
        controlsView!.setControlsPlaying()

        // tests
        XCTAssertTrue(controlsView!.playButton.isEnabled)
        XCTAssertTrue(controlsView!.stopButton.isEnabled)
        XCTAssertTrue(controlsView!.prevButton.isEnabled)
        XCTAssertTrue(controlsView!.nextButton.isEnabled)
        XCTAssertTrue(controlsView!.shuffleButton.isEnabled)
        XCTAssertTrue(controlsView!.shareButton.isEnabled)
    }

    func testPlayingStateImage() {
        /**
        expectations:
        - play button in in play state
        */

        // mocks 
        let expected = PlayButton.State.play

        // runnable
        controlsView!.setControlsPaused()

        // tests
        XCTAssertEqual(controlsView!.playButton.buttonState, expected)
    }

    func testPausedState() {
        /**
        expectations:
        - controls are in paused state
        */

        // runnable
        controlsView!.setControlsPaused()

        // tests
        XCTAssertTrue(controlsView!.playButton.isEnabled)
        XCTAssertTrue(controlsView!.stopButton.isEnabled)
        XCTAssertFalse(controlsView!.prevButton.isEnabled)
        XCTAssertFalse(controlsView!.nextButton.isEnabled)
        XCTAssertTrue(controlsView!.shuffleButton.isEnabled)
        XCTAssertFalse(controlsView!.shareButton.isEnabled)
    }

    func testPausedStateImage() {
        /**
        expectations:
        - play button shows pause
        */

        // mocks
        let expected = PlayButton.State.pause

        // runnable
        controlsView!.setControlsPlaying()

        // tests
        XCTAssertEqual(controlsView!.playButton.buttonState, expected)
    }

    func testStoppedState() {
        /**
        expectations:
        - play button in in stopped state
        */

        // runnable
        controlsView!.setControlsStopped()

        // tests
        XCTAssertTrue(controlsView!.playButton.isEnabled)
        XCTAssertFalse(controlsView!.stopButton.isEnabled)
        XCTAssertFalse(controlsView!.prevButton.isEnabled)
        XCTAssertFalse(controlsView!.nextButton.isEnabled)
        XCTAssertTrue(controlsView!.shuffleButton.isEnabled)
        XCTAssertFalse(controlsView!.shareButton.isEnabled)
    }

    func testStopStateImage() {
        /**
        expectations:
        - play button shows play
        */

        // mocks
        let expected = PlayButton.State.play

        // runnable
        controlsView!.setControlsStopped()

        // tests
        XCTAssertEqual(controlsView!.playButton.buttonState, expected)
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
        XCTAssertEqual(controlsView!.playButton.isEnabled, enabled)
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
        XCTAssertEqual(MPRemoteCommandCenter.shared().playCommand.isEnabled, enabled)
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
        XCTAssertEqual(controlsView!.stopButton.isEnabled, enabled)
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
        XCTAssertEqual(MPRemoteCommandCenter.shared().stopCommand.isEnabled, enabled)
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
        XCTAssertEqual(controlsView!.prevButton.isEnabled, enabled)
    }

    func testEnableRemotePrevious() {
        /**
         expectations:
         - remote previous button is enabled
         - remote seek backward is enabled
         */

        // mocks
        let enabled = true

        // runnable
        controlsView!.enablePrevious(enabled)

        // tests
        XCTAssertEqual(MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled, enabled)
        XCTAssertEqual(MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled, enabled)
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
        XCTAssertEqual(controlsView!.nextButton.isEnabled, enabled)
    }

    func testEnableRemoteNext() {
        /**
         expectations:
         - remote next button is enabled
         - remote seek forward is enabled
         */

        // mocks
        let enabled = true

        // runnable
        controlsView!.enableNext(enabled)

        // tests
        XCTAssertEqual(MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled, enabled)
        XCTAssertEqual(MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled, enabled)
    }

    func testEnableSeekBackwardsRemoteOnly() {
        /**
         expectations:
         - remote seek backwards is enabled
         */

        // mocks
        let enabled = true

        // runnable
        controlsView!.enableSeekBackwardsRemoteOnly(enabled)

        // tests
        XCTAssertEqual(MPRemoteCommandCenter.shared().previousTrackCommand.isEnabled, enabled)
        XCTAssertEqual(MPRemoteCommandCenter.shared().seekBackwardCommand.isEnabled, enabled)
    }

    func testEnableSeekForwardsRemoteOnly() {
        /**
         expectations:
         - remote seek forwards is enabled
         */

        // mocks
        let enabled = true

        // runnable
        controlsView!.enableSeekForwardsRemoteOnly(enabled)

        // tests
        XCTAssertEqual(MPRemoteCommandCenter.shared().nextTrackCommand.isEnabled, enabled)
        XCTAssertEqual(MPRemoteCommandCenter.shared().seekForwardCommand.isEnabled, enabled)
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
        XCTAssertEqual(controlsView!.shuffleButton.isEnabled, enabled)
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
        XCTAssertEqual(controlsView!.shareButton.isEnabled, enabled)
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
        XCTAssertEqual(controlsView!.repeatButton.isEnabled, enabled)
    }

    func testControlsViewDelegatePlayPressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectation(description: "ControlsViewDelegate.playPressed(_)")

        // mocks
        let mockButton = UIButton()

        // runnable
        controlsView!.playButtonPressed(mockButton)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testControlsViewDelegateStopPressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectation(description: "ControlsViewDelegate.stopPressed(_)")

        // mocks
        let mockButton = UIButton()

        // runnable
        controlsView!.stopButtonPressed(mockButton)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testControlsViewDelegatePrevPressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectation(description: "ControlsViewDelegate.prevPressed(_)")

        // mocks
        let mockButton = UIButton()

        // runnable
        controlsView!.prevButtonPressed(mockButton)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testControlsViewDelegateNextPressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectation(description: "ControlsViewDelegate.nextPressed(_)")

        // mocks
        let mockButton = UIButton()

        // runnable
        controlsView!.nextButtonPressed(mockButton)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testControlsViewDelegateShufflePressed() {
        /**
         expectations
         - delegate method called on button press
         */
        controlsExpectation = expectation(description: "ControlsViewDelegate.shufflePressed(_)")

        // mocks
        let mockButton = UIButton()

        // runnable
        controlsView!.shuffleButtonPressed(mockButton)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testControlsViewDelegateRepeatPressed() {
        /**
        expectations
        - delegate method called on button press
        */
        controlsExpectation = expectation(description: "ControlsViewDelegate.repeatPressed(_)")

        // mocks
        let mockButton = UIButton()

        // runnable
        controlsView!.repeatButtonPressed(mockButton)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ControlsViewDelegate

extension ControlsViewTests: ControlsViewDelegate {
    func playPressed(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func stopPressed(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func prevPressed(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func nextPressed(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func seekBackwardStart(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func seekBackwardEnd(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func seekForwardStart(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func seekForwardEnd(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func shufflePressed(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func sharePressed(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }

    func repeatPressed(_ sender: ControlsView) {
        if let controlsExpectation = controlsExpectation {
            controlsExpectation.fulfill()
        }
    }
}
