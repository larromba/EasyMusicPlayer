//
//  PlayerViewControllerTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 16/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import UIKit
import AVFoundation
import MediaPlayer
@testable import EasyMusic

private var musicPlayerExpectation: XCTestExpectation!
private var infoViewExpectation: XCTestExpectation!
private var controlsViewExpectation: XCTestExpectation!
private var scobbleViewExpectation: XCTestExpectation!
private var shareManagerExpectation: XCTestExpectation!
private var alertExpectation: XCTestExpectation!

var sharedTrack: Track!

class PlayerViewControllerTests: XCTestCase {
    var playerViewController: PlayerViewController!
    
    override func setUp() {
        super.setUp()
        playerViewController = UIStoryboard.main().instantiateInitialViewController() as! PlayerViewController
        playerViewController.view.layoutIfNeeded()
    }
    
    func testInitialState() {
        XCTAssert(musicPlayer.scrobbleView.enabled == false)
        
    }
    
    func testPlay() {
        /**
        expectations
        - Music player attempts to play
        - Info view updates
        - Controls are in playing state
        - Scrobble view is enabled
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.play()")
        infoViewExpectation = expectationWithDescription("infoView.setInfoFromTrack(_)")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func play() {
                musicPlayerExpectation.fulfill()
                self.delegate?.changedState(self, state: MusicPlayerState.Playing)
            }
        }
        
        class MockInfoView: InfoView {
            private override func className() -> String! { return "InfoView" }
            override func setInfoFromTrack(track: Track) {
                infoViewExpectation.fulfill()
            }
        }
        
        class MockControlsView: ControlsView {
            private override func className() -> String! { return "ControlsView" }
            private override func setControlsPlaying() {
                controlsViewExpectation.fulfill()
            }
        }
        
        class MockSrobbleView: ScrobbleView {
            private override func className() -> String! { return "ScrobbleView" }
            override var enabled: Bool! {
                get { return super.enabled }
                set { if newValue == true { scobbleViewExpectation.fulfill() } }
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockInfoView = MockInfoView()
        playerViewController._injectInfoView(mockInfoView)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.playButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayErrorNoMusic() {
        /**
        expectations
        - Controls are disabled
        - Scrobble view is disabled
        - An alert is thrown
        */
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsEnabled()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        alertExpectation = expectationWithDescription("UIAlertController.createAlertWithTitle(_, ...)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func play() {
                self.delegate?.threwError(self, error: MusicPlayerError.NoMusic)
            }
        }

        class MockControlsView: ControlsView {
            private override func className() -> String! { return "ControlsView" }
            private override func setControlsEnabled(enabled: Bool) {
                if enabled == false { controlsViewExpectation.fulfill() }
            }
        }
        
        class MockSrobbleView: ScrobbleView {
            private override func className() -> String! { return "ScrobbleView" }
            override var enabled: Bool! {
                get { return super.enabled }
                set { if newValue == false { scobbleViewExpectation.fulfill() } }
            }
        }
        
        class MockAlertController: UIAlertController {
            override private class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?) -> UIAlertController! {
                alertExpectation.fulfill()
                return UIAlertController()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        let mockAlertControllerType = MockAlertController.self
        playerViewController._injectAlertController(mockAlertControllerType)
        
        // tests
        let mockButton = UIButton()
        mockControlsView.playButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayErrorGeneric() {
        /**
        expectations
        - Music player attempts to play next track after alert is dismissed
        - Controls are disabled
        - Scrobble view is disabled
        - An alert is thrown
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.next()")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        alertExpectation = expectationWithDescription("UIAlertController.createAlertWithTitle(_, ...)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool! {
                return false
            }
            
            override func play() {
                self.delegate?.threwError(self, error: MusicPlayerError.Decode)
            }
            
            override func next() {
                musicPlayerExpectation.fulfill()
            }
        }
        
        class MockControlsView: ControlsView {
            private override func className() -> String! { return "ControlsView" }
            private override func setControlsEnabled(enabled: Bool) {
                if enabled == false { controlsViewExpectation.fulfill() }
            }
        }
        
        class MockSrobbleView: ScrobbleView {
            private override func className() -> String! { return "ScrobbleView" }
            override var enabled: Bool! {
                get { return super.enabled }
                set { if newValue == false { scobbleViewExpectation.fulfill() } }
            }
        }
        
        class MockAlertController: UIAlertController {
            override private class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?) -> UIAlertController! {
                alertExpectation.fulfill()
                return UIAlertController()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        let mockAlertControllerType = MockAlertController.self
        playerViewController._injectAlertController(mockAlertControllerType)
        
        // tests
        let mockButton = UIButton()
        mockControlsView.playButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPause() {
        /**
        expectations
        - Music player attempts to pause
        - Controls are in paused state
        - Scrobble view is disabled
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.pause()")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPaused()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool! {
                return true
            }
            
            override func pause() {
                musicPlayerExpectation.fulfill()
                self.delegate?.changedState(self, state: MusicPlayerState.Paused)
            }
        }
        
        class MockControlsView: ControlsView {
            private override func className() -> String! { return "ControlsView" }
            private override func setControlsPaused() {
                controlsViewExpectation.fulfill()
            }
        }
        
        class MockSrobbleView: ScrobbleView {
            private override func className() -> String! { return "ScrobbleView" }
            override var enabled: Bool! {
                get { return super.enabled }
                set { if newValue == false { scobbleViewExpectation.fulfill() } }
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.playButtonPressed(mockButton)

        // assertions
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
                musicPlayerExpectation.fulfill()
            }
        }

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.nextButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNextDisabled() {
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            private override func play() {
                self.delegate?.changedState(self, state: MusicPlayerState.Playing)
            }
            private override func numOfTracks() -> Int {
                return 1
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
                
        // tests
        let mockButton = UIButton()
        mockControlsView.playButtonPressed(mockButton)
        
        // assertions
        XCTAssert(mockControlsView.nextButton.enabled == false)
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
                musicPlayerExpectation.fulfill()
            }
        }

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.prevButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPreviousDisabled() {
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            private override func play() {
                self.delegate?.changedState(self, state: MusicPlayerState.Playing)
            }
            private override func numOfTracks() -> Int {
                return 1
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.playButtonPressed(mockButton)
        
        // assertions
        XCTAssert(mockControlsView.nextButton.enabled == false)
    }
    
    func testStop() {
        /**
        expectations
        - Music player attempts to stop
        - Controls are in stopped state
        - Scrobble view is disabled
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.stop()")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func stop() {
                musicPlayerExpectation.fulfill()
                self.delegate?.changedState(self, state: MusicPlayerState.Stopped)
            }
        }
        
        class MockControlsView: ControlsView {
            private override func className() -> String! { return "ControlsView" }
            private override func setControlsStopped() {
                controlsViewExpectation.fulfill()
            }
        }
        
        class MockSrobbleView: ScrobbleView {
            private override func className() -> String! { return "ScrobbleView" }
            override var enabled: Bool! {
                get { return super.enabled }
                set { if newValue == false { scobbleViewExpectation.fulfill() } }
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.stopButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testShuffle() {
        /**
        expectations
        - Music player attempts to shuffle
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.shuffle()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            var shuffleCount = 0
            
            override func stop() {}
            override func play() {}
            override func shuffle() {
                shuffleCount++ // called on init, so test is only valid for second call
                if shuffleCount == 2 {
                    musicPlayerExpectation.fulfill()
                }
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)

        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.shuffleButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testShare() {
        // expectations
        shareManagerExpectation = expectationWithDescription("shareManager.shareTrack(_, _)")
        
        // mocks
        class MockShareManager: ShareManager {
            private override func shareTrack(track: Track, presenter: UIViewController) {
                if sharedTrack == track {
                    shareManagerExpectation.fulfill()
                }
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            private override func currentTrack() -> Track! {
                sharedTrack = super.currentTrack()
                return sharedTrack
            }
        }
        
        let mockShareManager = MockShareManager()
        playerViewController._injectShareManager(mockShareManager)

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.shareButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testScrobbleTouchMoved() {
        /**
        expectations
        - Music player attempts to scrobble
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.skipTo(_)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func skipTo(time: NSTimeInterval) {
                musicPlayerExpectation.fulfill()
            }
        }
        
        class MockSrobbleView: ScrobbleView {
            private override func className() -> String! { return "ScrobbleView" }
            override var enabled: Bool! {
                get { return true }
                set { }
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        // tests
        mockScrobbleView.delegate?.touchEndedAtPercentage(mockScrobbleView, percentage: 0.2)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testScrobbleTouchEnd() {
        /**
        expectations
        - Music player attempts to scrobble
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.skipTo(_)")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func skipTo(time: NSTimeInterval) {
                musicPlayerExpectation.fulfill()
            }
        }
        
        class MockSrobbleView: ScrobbleView {
            private override func className() -> String! { return "ScrobbleView" }
            override var enabled: Bool! {
                get { return true }
                set { }
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)

        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        // tests
        mockScrobbleView.delegate?.touchEndedAtPercentage(mockScrobbleView, percentage: 0.2)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}