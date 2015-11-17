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
@testable import EasyMusic

var musicPlayerPlayExpectation: XCTestExpectation!
var musicPlayerPauseExpectation: XCTestExpectation!

var infoViewTrackInfoExpectation: XCTestExpectation!

var controlsViewPlayingExpectation: XCTestExpectation!
var controlsViewPausedExpectation: XCTestExpectation!

class PlayerViewControllerTests: XCTestCase {
    var playerViewController: PlayerViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        playerViewController = UIStoryboard.main().instantiateInitialViewController() as! PlayerViewController
        playerViewController.view.layoutIfNeeded()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPlay() {
        // expectations
        musicPlayerPlayExpectation = expectationWithDescription("musicPlayer.play()")
        infoViewTrackInfoExpectation = expectationWithDescription("infoView.setTrackInfo(_)")
        controlsViewPlayingExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func play() {
                musicPlayerPlayExpectation.fulfill()
                super.play()
            }
        }
        
        class MockInfoView: InfoView {
            private override func className() -> String! {
                return "InfoView"
            }
            
            override func setTrackInfo(trackInfo: TrackInfo) {
                infoViewTrackInfoExpectation.fulfill()
            }
        }
        
        class MockControlsView: ControlsView {
            private override func className() -> String! {
                return "ControlsView"
            }
            
            private override func setControlsPlaying() {
                controlsViewPlayingExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockInfoView = MockInfoView()
        playerViewController._injectInfoView(mockInfoView)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.playButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayNoTracks() {
        
    }
    
    func testPause() {
        // expectations
        musicPlayerPauseExpectation = expectationWithDescription("musicPlayer.pause()")
        controlsViewPausedExpectation = expectationWithDescription("controlsView.setControlsPaused()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool! {
                return true
            }
            
            override func pause() {
                musicPlayerPauseExpectation.fulfill()
                super.pause()
            }
        }
        
        class MockControlsView: ControlsView {
            private override func className() -> String! {
                return "ControlsView"
            }
            
            private override func setControlsPaused() {
                controlsViewPausedExpectation.fulfill()
            }
        }
        
        class MockAudioPlayer : AVAudioPlayer {
            private override func pause() {} // stub
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        let mockPlayer = MockAudioPlayer()
        mockMusicPlayer._injectPlayer(mockPlayer)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.playButtonPressed(mockButton)

        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNext() {
        
    }
    
    func testPrevious() {
        
    }
    
    func testStop() {
        
    }
    
    func testShuffle() {
        
    }
    
    func testShare() {
        
    }
    
    func testScrobble() {
        
    }
}