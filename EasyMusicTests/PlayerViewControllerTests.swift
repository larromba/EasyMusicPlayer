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

var musicPlayerExpectation: XCTestExpectation!
var infoViewExpectation: XCTestExpectation!
var controlsViewExpectation: XCTestExpectation!
var scobbleViewExpectation: XCTestExpectation!
var trackManagerExpectation: XCTestExpectation!
var alertExpectation: XCTestExpectation!

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
        musicPlayerExpectation = expectationWithDescription("musicPlayer.play()")
        infoViewExpectation = expectationWithDescription("infoView.setTrackInfo(_)")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func play() {
                musicPlayerExpectation.fulfill()
                super.play()
            }
        }
        
        class MockInfoView: InfoView {
            private override func className() -> String! { return "InfoView" }
            override func setTrackInfo(trackInfo: TrackInfo) {
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
    
    func testPlayNoTracks() {
        // expectations
        musicPlayerExpectation = expectationWithDescription("musicPlayer.play()")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        alertExpectation = expectationWithDescription("UIAlertController.createAlertWithTitle(_, ...)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func play() {
                musicPlayerExpectation.fulfill()
                super.play()
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
        
        class MockTrackManager: TrackManager {
            private override func createPlaylist() -> [TrackInfo]! {
                return []
            }
        }
        
        class MockAlertController: UIAlertController {
            override private class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?) -> UIAlertController! {
                alertExpectation.fulfill()
                return UIAlertController()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        let mockTrackManager = MockTrackManager()
        mockMusicPlayer._injectTrackManager(mockTrackManager)
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
    
    func testPlayError() {
        // expectations
        musicPlayerExpectation = expectationWithDescription("musicPlayer.play()")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        alertExpectation = expectationWithDescription("UIAlertController.createAlertWithTitle(_, ...)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool! {
                return false
            }
            
            override func play() {
                musicPlayerExpectation.fulfill()
                super.play()
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
        
        class MockTrackManager: TrackManager {
            private override func createPlaylist() -> [TrackInfo]! {
                return []
            }
        }
        
        class MockAlertController: UIAlertController {
            override private class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?) -> UIAlertController! {
                alertExpectation.fulfill()
                return UIAlertController()
            }
        }
        
        class MockAudioPlayer : AVAudioPlayer {
            private override func play() -> Bool {
                self.delegate?.audioPlayerDecodeErrorDidOccur!(self, error: nil)
                return false
            }
            private override func stop() {}
            override private var currentTime: NSTimeInterval { set {} get { return 0.0 } }
            override private var url: NSURL { return NSURL(string: "")! }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        let mockPlayer = MockAudioPlayer()
        let mockTrackManager = MockTrackManager()
        mockMusicPlayer._injectPlayer(mockPlayer)
        mockMusicPlayer._injectTrackManager(mockTrackManager)
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
        // expectations
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
                super.pause()
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
        
        class MockAudioPlayer : AVAudioPlayer {
            private override func pause() {}
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        let mockPlayer = MockAudioPlayer()
        mockMusicPlayer._injectPlayer(mockPlayer)
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
        // expectations
        musicPlayerExpectation = expectationWithDescription("musicPlayer.next()")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func next() {
                musicPlayerExpectation.fulfill()
                super.next()
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
        
        class MockAudioPlayer : AVAudioPlayer {
            private override func play() -> Bool { return true }
            private override func stop() {}
            override private var currentTime: NSTimeInterval { set {} get { return 0.0 } }
            override private var url: NSURL { return NSURL(string: "")! }
        }
 
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        let mockPlayer = MockAudioPlayer()
        mockMusicPlayer._injectPlayer(mockPlayer)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.nextButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPrevious() {
        // expectations
        musicPlayerExpectation = expectationWithDescription("musicPlayer.previous()")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func previous() {
                musicPlayerExpectation.fulfill()
                super.previous()
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
        
        class MockAudioPlayer : AVAudioPlayer {
            private override func play() -> Bool { return true }
            private override func stop() {}
            override private var currentTime: NSTimeInterval { set {} get { return 0.0 } }
            override private var url: NSURL { return NSURL(string: "")! }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        let mockPlayer = MockAudioPlayer()
        mockMusicPlayer._injectPlayer(mockPlayer)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        
        let mockControlsView = MockControlsView()
        playerViewController._injectControlsView(mockControlsView)
        mockControlsView.delegate = playerViewController
        
        let mockScrobbleView = MockSrobbleView()
        playerViewController._injectScrobbleView(mockScrobbleView)
        mockScrobbleView.delegate = playerViewController
        
        // tests
        let mockButton = UIButton()
        mockControlsView.prevButtonPressed(mockButton)
        
        // assertions
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testStop() {
        // expectations
        musicPlayerExpectation = expectationWithDescription("musicPlayer.stop()")
        controlsViewExpectation = expectationWithDescription("controlsView.setControlsPlaying()")
        scobbleViewExpectation = expectationWithDescription("scrobbleView.enabled")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func stop() {
                musicPlayerExpectation.fulfill()
                super.stop()
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
        
        class MockAudioPlayer : AVAudioPlayer {
            private override func play() -> Bool { return true }
            private override func stop() {}
            override private var currentTime: NSTimeInterval { set {} get { return 0.0 } }
            override private var url: NSURL { return NSURL(string: "")! }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        let mockPlayer = MockAudioPlayer()
        mockMusicPlayer._injectPlayer(mockPlayer)
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
        // expectations
        musicPlayerExpectation = expectationWithDescription("musicPlayer.shuffle()")
        trackManagerExpectation = expectationWithDescription("trackManager.shuffleTracks()")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            var methodCallCount = 0
            
            override func stop() {
                if methodCallCount == 0 { methodCallCount++ }
            }
            override func shuffle() {
                if methodCallCount == 1 {
                    methodCallCount++
                    super.shuffle()
                }
            }
            override func play() {
                if methodCallCount == 2 { musicPlayerExpectation.fulfill() }
            }
        }
        
        class MockTrackManager: TrackManager {
            private override func shuffleTracks() {
                trackManagerExpectation.fulfill()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController)
        playerViewController._injectMusicPlayer(mockMusicPlayer)
        let mockTrackManager = MockTrackManager()
        mockMusicPlayer._injectTrackManager(mockTrackManager)
        
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
        
    }
    
    func testScrobble() {
        
    }
}