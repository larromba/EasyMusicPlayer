//
//  MusicPlayerTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import AVFoundation
@testable import EasyMusic

private var musicPlayerExpectation: XCTestExpectation!
private var audioPlayerExpectation: XCTestExpectation!
private var trackManagerExpectation: XCTestExpectation!
private var musicPlayerDelegateErrorExpectation: XCTestExpectation!
private var musicPlayerDelegateStateExpectation: XCTestExpectation!
private var musicPlayerDelegateTimeExpectation: XCTestExpectation!
private var expectedError: MusicPlayerError?
private var expectedState: MusicPlayerState?
private var expectedPlaybackTime: NSTimeInterval?
private let audioUrl: NSURL! = NSURL(fileURLWithPath: Constant.Path.DummyAudio)

class MusicPlayerTests: XCTestCase {
    var musicPlayer: EasyMusic.MusicPlayer!
    
    override func setUp() {
        super.setUp()
        musicPlayer = MusicPlayer(delegate: self)
    }
    
    override func tearDown() {
        super.tearDown()
        
        expectedError = nil
        expectedState = nil
        expectedPlaybackTime = nil
    }
    
    func testAudioSessionOnInit() {
        /**
        expectations
        - enableAudioSession should be set to true on init
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.enableAudioSession(_)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func enableAudioSession(enable: Bool) {
                if enable == true {
                    musicPlayerExpectation.fulfill()
                }
            }
        }
        
        // runnable
        _ = MockMusicPlayer(delegate: self)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioSessionOnDeinit() {
        /**
        expectations
        - enableAudioSession should be set to false on deinit
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.enableAudioSession(_)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func enableAudioSession(enable: Bool) {
                if enable == false {
                    musicPlayerExpectation.fulfill()
                }
            }
        }
        
        // runnable
        _ = MockMusicPlayer(delegate: self)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlay() {
        /**
        expectations
        - audio plays
        - state changes
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.play()")
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")

        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool {
                audioPlayerExpectation.fulfill()
                return true
            }
        }
        
        class MockTrackManager: TrackManager {
            override func numOfTracks() -> Int { return 1 }
            override func currentTrack() -> Track! {
                return Track(artist: "", title: "", duration: 0, artwork: nil, url: audioUrl)
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
       
        expectedState = MusicPlayerState.Playing
        
        // runnable
        musicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayNoTracks() {
        /**
        expectations
        - error thrown
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockTrackManager: TrackManager {
            override func numOfTracks() -> Int { return 0 }
        }

        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        expectedError = MusicPlayerError.NoMusic
        
        // runnable
        musicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayInvalidTrackUrl() {
        /**
        expectations
        - error thrown
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockTrackManager: TrackManager {
            override func numOfTracks() -> Int { return 1 }
            override func currentTrack() -> Track! {
                return Track(artist: "", title: "", duration: 0, artwork: nil, url: NSURL(string: "")!)
            }
        }
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        expectedError = MusicPlayerError.InvalidUrl
        
        // runnable
        musicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayInvalidPlayer() {
        /**
        expectations
        - error thrown
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockTrackManager: TrackManager {
            override func numOfTracks() -> Int { return 1 }
            override func currentTrack() -> Track! {
                return Track(artist: "", title: "", duration: 0, artwork: nil, url: NSURL(string: "fakeUrl")!)
            }
        }
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        expectedError = MusicPlayerError.PlayerInit
        
        // runnable
        musicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayAVError1() {
        /**
        expectations
        - error thrown
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func prepareToPlay() -> Bool {
                return false
            }
        }
        
        class MockTrackManager: TrackManager {
            override func numOfTracks() -> Int { return 1 }
            override func currentTrack() -> Track! {
                return Track(artist: "", title: "", duration: 0, artwork: nil, url: audioUrl)
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        expectedError = MusicPlayerError.AVError
        
        // runnable
        musicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayAVError2() {
        /**
        expectations
        - error thrown
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool {
                return false
            }
        }
        
        class MockTrackManager: TrackManager {
            override func numOfTracks() -> Int { return 1 }
            override func currentTrack() -> Track! {
                return Track(artist: "", title: "", duration: 0, artwork: nil, url: audioUrl)
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        expectedError = MusicPlayerError.AVError
        
        // runnable
        musicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPause() {
        /**
        expectations
        - audio pauses
        - state changes
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.pause()")
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func pause() {
                audioPlayerExpectation.fulfill()
            }
        }
        
        class MockTrackManager: TrackManager {
            override func numOfTracks() -> Int { return 1 }
            override func currentTrack() -> Track! {
                return Track(artist: "", title: "", duration: 0, artwork: nil, url: audioUrl)
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        expectedState = MusicPlayerState.Paused
        
        // runnable
        musicPlayer.pause()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testStop() {
        /**
        expectations
        - audio stops
        - changes state
        - changes playback time
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.stop()")
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        musicPlayerDelegateTimeExpectation = expectationWithDescription("MusicPlayerDelegate.changedPlaybackTime(_, _)")

        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func stop() {
                audioPlayerExpectation.fulfill()
            }
        }
        
        class MockTrackManager: TrackManager {
            override func numOfTracks() -> Int { return 1 }
            override func currentTrack() -> Track! {
                return Track(artist: "", title: "", duration: 0, artwork: nil, url: audioUrl)
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        expectedState = MusicPlayerState.Stopped
        expectedPlaybackTime = 0.0
        
        // runnable
        musicPlayer.stop()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPrevious() {
        /**
        expectations
        - track manager cue's previous track
        */
        trackManagerExpectation = expectationWithDescription("trackManager.previous()")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool { return true }
            override private func stop() { }
        }
        
        class MockTrackManager: TrackManager {
            override func cuePrevious() -> Bool {
                trackManagerExpectation.fulfill()
                return true
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
                
        // runnable
        musicPlayer.previous()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPreviousFalse() {
        /**
        expectations
        - music player play's current track from start (as no previous tracks)
        */
        musicPlayerDelegateTimeExpectation = expectationWithDescription("MusicPlayerDelegate.changedPlaybackTime(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool { return true }
            override private func stop() { }
        }
        
        class MockTrackManager: TrackManager {
            override func cuePrevious() -> Bool { return false }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        expectedPlaybackTime = 0.0
        
        // runnable
        musicPlayer.previous()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNext() {
        /**
        expectations
        - track manager cue's next track
        */
        trackManagerExpectation = expectationWithDescription("trackManager.next()")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool { return true }
            override private func stop() { }
        }
        
        class MockTrackManager: TrackManager {
            override func cueNext() -> Bool! {
                trackManagerExpectation.fulfill()
                return true
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        // runnable
        musicPlayer.next()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNextFalse() {
        /**
         expectations
         - music player shouldn't play next track
         */
        let waitExpectation = expectationWithDescription("audioPlayer.play() shouldn't be called")
        performAfterDelay(1) { () -> () in
            waitExpectation.fulfill()
        }
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool {
                XCTFail()
                return false
            }
        }
        
        class MockTrackManager: TrackManager {
            override func cueNext() -> Bool! { return false }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        let mockTrackManager = MockTrackManager()
        musicPlayer._injectTrackManager(mockTrackManager)
        
        // runnable
        musicPlayer.next()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in })
    }
    
    func testSkipTo() {
        /**
        expectations
        - track manager cue's next track
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.currentTime")
        musicPlayerDelegateTimeExpectation = expectationWithDescription("MusicPlayerDelegate.changedPlaybackTime(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool { return true }
            override private func stop() { }
            override private var currentTime: NSTimeInterval {
                set {
                    if newValue == expectedPlaybackTime {
                        audioPlayerExpectation.fulfill()
                    }
                }
                get { return super.currentTime }
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer._injectPlayer(mockAudioPlayer)
        
        expectedPlaybackTime = 2.0
        
        // runnable
        musicPlayer.skipTo(expectedPlaybackTime!)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ScrobbleViewDelegate
extension MusicPlayerTests: MusicPlayerDelegate {
    func threwError(sender: EasyMusic.MusicPlayer, error: MusicPlayerError) {
        if expectedError != nil && expectedError == error {
            musicPlayerDelegateErrorExpectation.fulfill()
        }
    }
    
    func changedState(sender: EasyMusic.MusicPlayer, state: MusicPlayerState) {
        if expectedState != nil && expectedState == state {
            musicPlayerDelegateStateExpectation.fulfill()
        }
    }
    
    func changedPlaybackTime(sender: EasyMusic.MusicPlayer, playbackTime: NSTimeInterval) {
        if expectedPlaybackTime != nil && expectedPlaybackTime == playbackTime {
            musicPlayerDelegateTimeExpectation.fulfill()
        }
    }
}