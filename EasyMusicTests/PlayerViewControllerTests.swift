//
//  PlayerViewControllerTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 16/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

// TODO: - Analytics, add alert test

import XCTest
import UIKit
import AVFoundation
import MediaPlayer
@testable import EasyMusic

private var musicPlayerExpectation: XCTestExpectation?
private var infoViewExpectation: XCTestExpectation?
private var controlsViewExpectation: XCTestExpectation?
private var shareManagerExpectation: XCTestExpectation?
private var analyticsExpectation: XCTestExpectation?
private var sharedTrack: Track!
private var _isPlaying: Bool = false

class PlayerViewControllerTests: XCTestCase {
    private var playerViewController: PlayerViewController?
    
    override func setUp() {
        super.setUp()
        
        playerViewController = UIStoryboard.main().instantiateInitialViewController() as? PlayerViewController
        playerViewController!.view.layoutIfNeeded()
        UIApplication.sharedApplication().keyWindow!.rootViewController = playerViewController
    }
    
    override func tearDown() {
        super.tearDown()
        
        NSNotificationCenter.defaultCenter().removeObserver(playerViewController!)
        playerViewController = nil
        musicPlayerExpectation = nil
        infoViewExpectation = nil
        controlsViewExpectation = nil
        shareManagerExpectation = nil
        analyticsExpectation = nil
        Analytics.__shared = Analytics()
    }
    
    func testScreenAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectationWithDescription("analytics.sendScreenNameEvent(_)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendScreenNameEvent(screenName: String) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        // runnable
        playerViewController!.viewDidAppear(false)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }

    func testPlay() {
        /**
        expectations
        - Music player attempts to play
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.play()")
        analyticsExpectation = expectationWithDescription("analytics.sendButtonPressEvent(_, _)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func play() {
                musicPlayerExpectation!.fulfill()
            }
        }
        
        class MockAnalytics: Analytics {
            override func sendButtonPressEvent(event: String, classId: String) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer

        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockControlsView = ControlsView()
        mockControlsView.delegate = playerViewController
        playerViewController!.__controlsView = mockControlsView
        
        let mockButton = PlayButton()

        // runnable
        mockControlsView.playButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlaying() {
        /**
        expectations
        - Info view updates
        - Controls are in playing state
        - Scrubber view is enabled
        */
        infoViewExpectation = expectationWithDescription("infoView.setInfoFromTrack(_)")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        
        // mocks
        class MockInfoView: InfoView {
            var setInfoFromTrack: Bool = false
            var setTrackPosition: Bool = false
            override func className() -> String { return "InfoView" }
            override func setInfoFromTrack(track: Track) {
                setInfoFromTrack = true
                checkExpectation()
            }
            override func setTrackPosition(trackPosition: Int, totalTracks: Int) {
                setTrackPosition = true
                checkExpectation()
            }
            func checkExpectation() {
                if setInfoFromTrack && setTrackPosition {
                    infoViewExpectation!.fulfill()
                }
            }
        }
        
        class MockControlsView: ControlsView {
            override func className() -> String { return "ControlsView" }
            override func setControlsPlaying() {
                controlsViewExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockInfoView = MockInfoView()
        playerViewController!.__infoView = mockInfoView
        
        let mockControlsView = MockControlsView()
        mockControlsView.delegate = playerViewController
        playerViewController!.__controlsView = mockControlsView
        
        playerViewController!.__scrubberView.userInteractionEnabled = false
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.Playing)

        // tests
        XCTAssertTrue(playerViewController!.__scrubberView.userInteractionEnabled)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testControlsStateAfterEnteringExitingApp1() {
        /**
        expectations
        - controls are in stopped state
            -- leaving app whilst audio is playing
            -- audio stops
            -- entering app and audio has stopped
        */
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsStopped()")

        // mocks
        class MockControlsView: ControlsView {
            private override func className() -> String { return "ControlsView" }
            private override func setControlsStopped() {
                controlsViewExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool {
                return _isPlaying
            }
        }
        
        class MockAudioPlayer: AVAudioPlayer {
            override var playing: Bool { return false }
            private override func stop() { }
            override var currentTime: NSTimeInterval {
                get { return 0.0 }
                set {}
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        let mockAudioPlayer = MockAudioPlayer()
        mockMusicPlayer.__player = mockAudioPlayer
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = MockControlsView()
        mockControlsView.delegate = playerViewController
        mockControlsView.setControlsPlaying()
        playerViewController!.__controlsView = mockControlsView

        // runnable
        _isPlaying = true
        var notification = NSNotification(name: UIApplicationWillResignActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        _isPlaying = false
        notification = NSNotification(name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        // tests
        XCTAssertFalse(playerViewController!.__scrubberView.userInteractionEnabled)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioStopsOnEnteringAppAndThingsWentHorriblyWrong() {
        /**
        expectations
        - audio stops
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.stop()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return false }
            override func stop() {
                musicPlayerExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = ControlsView()
        mockControlsView.delegate = playerViewController
        mockControlsView.setControlsPlaying()
        playerViewController!.__controlsView = mockControlsView
        
        // runnable
        let notification = NSNotification(name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNoMusicErrorIsThrown() {
        /**
         expectations
         - error alert is thrown
         */
        
        // mocks
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)

        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayer.Error.NoMusic)
        
        // tests
        XCTAssertTrue(playerViewController!.presentedViewController is UIAlertController)
    }
    
    func testNoMusicErrorIsThrownOnBecomingActive() {
        /**
         expectations
         - error alert is thrown
         */
         
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 0 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        // runnable
        let notification = NSNotification(name: UIApplicationDidBecomeActiveNotification, object: nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        // tests
        XCTAssertTrue(playerViewController!.presentedViewController is UIAlertController)
    }
    
    func testNoMusicErrorDismissAction() {
        /**
         expectations
         - alert is presented after button pressed to dismiss original alert
         */
        let waitExpectation = expectationWithDescription("wait")
        
        // mocks
        class MockAlertController: UIAlertController {
            var mockButtonAction: (Void -> Void)!
            
            override class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?, buttonAction: (Void -> Void)?) -> UIAlertController {
                let alert = MockAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.mockButtonAction = buttonAction
                return alert
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 0 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        playerViewController!.__AlertController = MockAlertController.self
        
        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayer.Error.NoMusic)
        
        // tests
        let mockAlertController = playerViewController!.presentedViewController as! MockAlertController
        mockAlertController.dismissViewControllerAnimated(false) { () -> Void in
            XCTAssertNil(self.playerViewController!.presentedViewController) // for sanity only
            mockAlertController.mockButtonAction()
            XCTAssertTrue(self.playerViewController!.presentedViewController is UIAlertController)
            waitExpectation.fulfill()
        }
    
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNoVolumeErrorIsThrown() {
        /**
         expectations
         - error alert is thrown
         */
         
         // mocks
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        
        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayer.Error.NoVolume)
        
        // tests
        XCTAssertTrue(playerViewController!.presentedViewController is UIAlertController)
    }
    
    func testPlayErrorGeneric() {
        /**
        expectations
        - music player attempts to play next track after alert is dismissed
        - an error alert is thrown
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.next()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 2 }
            override var currentTrackNumber: Int { return 1 }
            override func next() {
                musicPlayerExpectation!.fulfill()
            }
        }
        
        class MockAlertController: UIAlertController {
            var mockButtonAction: (Void -> Void)!
            
            override class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?, buttonAction: (Void -> Void)?) -> UIAlertController {
                let alert = MockAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                alert.mockButtonAction = buttonAction
                return alert
            }
        }

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        playerViewController!.__AlertController = MockAlertController.self
        
        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayer.Error.Decode)
        
        // tests
        XCTAssertTrue(playerViewController!.presentedViewController is UIAlertController)
        
        let mockAlertController = playerViewController!.presentedViewController as! MockAlertController
        mockAlertController.mockButtonAction()
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPause() {
        /**
        expectations
        - Music player attempts to pause
        - Analytics event fired
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.pause()")
        analyticsExpectation = expectationWithDescription("analytics.sendButtonPressEvent(_, _)")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override func pause() {
                musicPlayerExpectation!.fulfill()
            }
        }
        
        class MockAnalytics: Analytics {
            override func sendButtonPressEvent(event: String, classId: String) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockControlsView = ControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        let mockButton = PlayButton()
        
        // runnable
        mockControlsView.playButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPaused() {
        /**
        expectations
        - Controls are in paused state
        - Scrubber view is disabled
        */
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPaused()")
        
        // mocks
        class MockControlsView: ControlsView {
            override func className() -> String { return "ControlsView" }
            override func setControlsPaused() {
                controlsViewExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = MockControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.Paused)
        
        // tests
        XCTAssertFalse(playerViewController!.__scrubberView.userInteractionEnabled)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNext() {
        /**
        expectations
        - Music player attempts next track
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.next()")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func next() {
                musicPlayerExpectation!.fulfill()
            }
        }

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = ControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        let mockButton = UIButton()

        // runnable
        mockControlsView.nextButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNextDisabled() {
        /**
         expectations
         - button is disabled
         */
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.Playing)
        
        // tests
        XCTAssertFalse(playerViewController!.__controlsView.nextButton.enabled)
    }
    
    func testNextRepeatAll() {
        /**
         expectations
         - button not disabled
         */
         
         // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.repeatMode = MusicPlayer.RepeatMode.All
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.Playing)
        
        // tests
        XCTAssertTrue(playerViewController!.__controlsView.nextButton.enabled)
    }
    
    func testPrevious() {
        /**
        expectations
        - Music player attempts previous track
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.previous()")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func previous() {
                musicPlayerExpectation!.fulfill()
            }
        }

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = ControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        let mockButton = UIButton()

        // runnable
        mockControlsView.prevButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPreviousDisabled() {
        /**
         expectations
         - button is disabled
         */
         
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.Playing)
        
        // tests
        XCTAssertFalse(playerViewController!.__controlsView.prevButton.enabled)
    }
    
    func testPreviousRepeatAll() {
        /**
        expectations
        - button not disabled
        */

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.repeatMode = MusicPlayer.RepeatMode.All
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.Playing)
        
        // tests
        XCTAssertTrue(playerViewController!.__controlsView.prevButton.enabled)
    }

    func testStop() {
        /**
        expectations
        - Music player attempts to stop
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.stop()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func stop() {
                musicPlayerExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = ControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        let mockButton = UIButton()
        
        // runnable
        mockControlsView.stopButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testStopped() {
        /**
        expectations
        - Controls are in stopped state
        - Scrubber view is disabled
        */
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsStopped()")
        
        // mocks
        class MockControlsView: ControlsView {
            override func className() -> String { return "ControlsView" }
            override func setControlsStopped() {
                controlsViewExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = MockControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.Stopped)
        
        // tests
        XCTAssertFalse(playerViewController!.__scrubberView.userInteractionEnabled)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testFinished() {
        /**
        expectations
        - Controls are in stopped state
        - Scrubber view is disabled
        - Info is cleared
        */
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsStopped()")
        infoViewExpectation = expectationWithDescription("infoView.clearInfo()")
        
        // mocks
        class MockControlsView: ControlsView {
            override func className() -> String { return "ControlsView" }
            override func setControlsStopped() {
                controlsViewExpectation!.fulfill()
            }
        }
        
        class MockInfoView: InfoView {
            override func className() -> String { return "InfoView" }
            override func clearInfo() {
                infoViewExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = MockControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        let mockInfoView = MockInfoView()
        playerViewController!.__infoView = mockInfoView
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.Finished)
        
        // tests
        XCTAssertFalse(playerViewController!.__scrubberView.userInteractionEnabled)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testShuffle() {
        /**
        expectations
        - Music player shuffles
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.shuffle()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            var shuffleCount = 0
            
            override func stop() {}
            override func play() {}
            override func shuffle() {
                shuffleCount += 1 // called on init, so test is only valid for second call
                if shuffleCount == 2 {
                    musicPlayerExpectation!.fulfill()
                }
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer

        let mockControlsView = ControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        let mockButton = ShuffleButton()

        // runnable
        mockControlsView.shuffleButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testShare() {
        /**
        expectations
        - track is shared
        */
        shareManagerExpectation = expectationWithDescription("shareManager.shareTrack(_, _)")
        
        // mocks
        class MockShareManager: ShareManager {
            override func shareTrack(track: Track, presenter: UIViewController, sender: UIView, completion: ((ShareManager.Result, String?) -> Void)?) {
                if sharedTrack == track {
                    shareManagerExpectation!.fulfill()
                }
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var currentResolvedTrack: Track {
                sharedTrack = super.currentResolvedTrack
                return sharedTrack
            }
        }
        
        let mockShareManager = MockShareManager()
        playerViewController!.__shareManager = mockShareManager

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockControlsView = ControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        let mockButton = UIButton()

        // runnable
        mockControlsView.shareButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testRepeat() {
        /**
        expectations
        - repeat mode changes
        */

        // mocks
        let mockControlsView = ControlsView()
        mockControlsView.repeatButton.setButtonState(RepeatButton.State.All)
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.repeatMode = MusicPlayer.RepeatMode.All
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockButton = RepeatButton()
        let expectedRepeatMode = MusicPlayer.RepeatMode.None
        
        // runnable
        mockControlsView.repeatButtonPressed(mockButton)
        
        // tests
        XCTAssertEqual(mockMusicPlayer.repeatMode, expectedRepeatMode)
    }
    
    func testRepeatLoaded() {
        /**
         expectations
         - repeat mode loaded on launch
         */
         
        // mocks
        UserData.repeatMode = MusicPlayer.RepeatMode.All
       
        let expectedRepeatButtonState = RepeatButton.State.All

        // runnable
        playerViewController!.viewDidLoad()
        
        // tests
        XCTAssertEqual(playerViewController!.__controlsView.repeatButton.buttonState, expectedRepeatButtonState)
    }
    
    func testScrubberTouchMoved() {
        /**
        expectations
        - info view time is updated
        */
        infoViewExpectation = expectationWithDescription("infoView.setTime(_, _)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var time: NSTimeInterval {
                set {}
                get { return 0.0 }
            }
        }
        
        class MockInfoView: InfoView {
            private override func className() -> String { return "InfoView" }
            override func setTime(time: NSTimeInterval, duration: NSTimeInterval) {
                infoViewExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockInfoView = MockInfoView()
        playerViewController!.__infoView = mockInfoView
        
        // runnable
        playerViewController!.__scrubberView.delegate!.touchMovedToPercentage(playerViewController!.__scrubberView, percentage: 0.2)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testScrubberTouchEnded() {
        /**
        expectations
        - Music player attempts to scrub
        - Remote time set
        */
        infoViewExpectation = expectationWithDescription("infoView.setRemoteTime(_, _)")
        musicPlayerExpectation = expectationWithDescription("musicPlayer.time")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var time: NSTimeInterval {
                set { musicPlayerExpectation!.fulfill() }
                get { return 0.0 }
            }
        }
        
        class MockInfoView: InfoView {
            private override func className() -> String { return "InfoView" }
            override func setRemoteTime(time: NSTimeInterval, duration: NSTimeInterval) {
                infoViewExpectation!.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        playerViewController!.__musicPlayer = mockMusicPlayer
        
        let mockInfoView = MockInfoView()
        playerViewController!.__infoView = mockInfoView
        
        // runnable
        playerViewController!.__scrubberView.delegate!.touchEndedAtPercentage(playerViewController!.__scrubberView, percentage: 0.2)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}