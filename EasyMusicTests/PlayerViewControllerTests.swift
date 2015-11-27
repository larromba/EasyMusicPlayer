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

var sharedTrack: Track!

class PlayerViewControllerTests: XCTestCase {
    var playerViewController: PlayerViewController!
    
    override func setUp() {
        super.setUp()
        
        playerViewController = UIStoryboard.main().instantiateInitialViewController() as! PlayerViewController
        playerViewController.view.layoutIfNeeded()
        UIApplication.sharedApplication().keyWindow?.rootViewController = playerViewController
    }
    
    func testPlay() {
        /**
        expectations
        - Music player attempts to play
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.play()")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func play() {
                musicPlayerExpectation.fulfill()
            }
        }

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)

        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockButton = UIButton()

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
        - Scrobble view is enabled
        */
        infoViewExpectation = expectationWithDescription("infoView.setInfoFromTrack(_)")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        
        // mocks
        class MockInfoView: InfoView {
            override func className() -> String! { return "InfoView" }
            override func setInfoFromTrack(track: Track) {
                infoViewExpectation.fulfill()
            }
        }
        
        class MockControlsView: ControlsView {
            override func className() -> String! { return "ControlsView" }
            override func setControlsPlaying() {
                controlsViewExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockInfoView = MockInfoView()
        playerViewController._injectInfoView(mockInfoView)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = ScrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.enabled = false
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayerState.Playing)

        // tests
        XCTAssertTrue(mockScrobbleView.enabled)
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
        
        // mocks
        class MockControlsView: ControlsView {
            override func className() -> String! { return "ControlsView" }
            override func setControlsEnabled(enabled: Bool) {
                if enabled == false { controlsViewExpectation.fulfill() }
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = ScrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.enabled = true
        
        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayerError.NoMusic)
        
        // tests
        XCTAssertFalse(mockScrobbleView.enabled)
        XCTAssertTrue(self.playerViewController.presentedViewController!.isKindOfClass(UIAlertController.classForCoder()))
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
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func next() {
                musicPlayerExpectation.fulfill()
            }
        }
        
        class MockControlsView: ControlsView {
            override func className() -> String! { return "ControlsView" }
            override func setControlsEnabled(enabled: Bool) {
                if enabled == false { controlsViewExpectation.fulfill() }
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = ScrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.enabled = true

        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayerError.Decode)
        
        // tests
        XCTAssertFalse(mockScrobbleView.enabled)
        XCTAssertTrue(self.playerViewController.presentedViewController!.isKindOfClass(UIAlertController.classForCoder()))
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPause() {
        /**
        expectations
        - Music player attempts to pause
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.pause()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override func pause() {
                musicPlayerExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockButton = UIButton()
        
        // runnable
        mockControlsView.playButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPaused() {
        /**
        expectations
        - Controls are in paused state
        - Scrobble view is disabled
        */
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPaused()")
        
        // mocks
        class MockControlsView: ControlsView {
            override func className() -> String! { return "ControlsView" }
            override func setControlsPaused() {
                controlsViewExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = ScrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.enabled = true
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayerState.Paused)
        
        // tests
        XCTAssertFalse(mockScrobbleView.enabled)
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
        
        let mockButton = UIButton()

        // runnable
        mockControlsView.nextButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNextDisabled() {
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayerState.Playing)
        
        // tests
        XCTAssertFalse(mockControlsView.nextButton.enabled)
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
        
        let mockButton = UIButton()

        // runnable
        mockControlsView.prevButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
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
                musicPlayerExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = ControlsView()
        playerViewController._injectControlsView(mockControlsView)
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
        - Scrobble view is disabled
        */
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsStopped()")
        
        // mocks
        class MockControlsView: ControlsView {
            override func className() -> String! { return "ControlsView" }
            override func setControlsStopped() {
                controlsViewExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = ScrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.enabled = true
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayerState.Stopped)
        
        // tests
        XCTAssertFalse(mockScrobbleView.enabled)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testFinished() {
        /**
        expectations
        - Controls are in stopped state
        - Scrobble view is disabled
        */
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsStopped()")
        
        // mocks
        class MockControlsView: ControlsView {
            override func className() -> String! { return "ControlsView" }
            override func setControlsStopped() {
                controlsViewExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = ScrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.enabled = true
        
        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayerState.Finished)
        
        // tests
        XCTAssertFalse(mockScrobbleView.enabled)
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
        
        let mockButton = UIButton()

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
            override func shareTrack(track: Track, presenter: UIViewController) {
                if sharedTrack == track {
                    shareManagerExpectation.fulfill()
                }
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var currentTrack: Track! {
                sharedTrack = super.currentTrack
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
        
        let mockButton = UIButton()

        // runnable
        mockControlsView.shareButtonPressed(mockButton)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testScrobbleTouchMoved() {
        /**
        expectations
        - Music player attempts to scrobble
        */
        infoViewExpectation = expectationWithDescription("infoView.setTime(_, _)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func skipTo(time: NSTimeInterval) { }
        }
        
        class MockInfoView: InfoView {
            private override func className() -> String! { return "InfoView" }
            override func setTime(time: NSTimeInterval, duration: NSTimeInterval) {
                infoViewExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockInfoView = MockInfoView()
        playerViewController._injectInfoView(mockInfoView)
        
        let mockScrobbleView = ScrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        mockScrobbleView.enabled = true
        
        // runnable
        mockScrobbleView.delegate!.touchMovedToPercentage(mockScrobbleView, percentage: 0.2)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testScrobbleTouchEnded() {
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
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockScrobbleView = ScrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        mockScrobbleView.enabled = true
        
        // runnable
        mockScrobbleView.delegate!.touchEndedAtPercentage(mockScrobbleView, percentage: 0.2)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}