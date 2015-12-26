//
//  MusicPlayerTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import MediaPlayer
import AVFoundation
@testable import EasyMusic

private var musicPlayerExpectation: XCTestExpectation?
private var audioPlayerExpectation: XCTestExpectation?
private var trackManagerExpectation: XCTestExpectation?
private var analyticsExpectation: XCTestExpectation?
private var musicPlayerDelegateErrorExpectation: XCTestExpectation?
private var musicPlayerDelegateStateExpectation: XCTestExpectation?
private var musicPlayerDelegateTimeExpectation: XCTestExpectation?
private var expectedError: EasyMusic.MusicPlayer.Error?
private var expectedState: EasyMusic.MusicPlayer.State?
private var expectedPlaybackTime: NSTimeInterval?
private var expectedPlaybackTimeRough: NSTimeInterval?
private var methodOrder: [Int]?
private var audioUrl: NSURL!

class MusicPlayerTests: XCTestCase {
    private var musicPlayer: EasyMusic.MusicPlayer?
    private var mockPlaylist: [MPMediaItem]?

    override func setUp() {
        super.setUp()
        
        musicPlayer = MusicPlayer(delegate: self)
        methodOrder = []
        
        class MockMediaItem: MPMediaItem {
            override var artist: String { return "artist" }
            override var title: String { return "title" }
            override var playbackDuration: NSTimeInterval { return 9.0 }
            override var artwork: MPMediaItemArtwork { return MPMediaItemArtwork(image: UIImage()) }
            override var assetURL: NSURL { return NSURL(fileURLWithPath: Constant.Path.DummyAudio) }
        }

        mockPlaylist = [
            MockMediaItem(),
            MockMediaItem(),
            MockMediaItem()]
        
#if !((arch(i386) || arch(x86_64)) && os(iOS)) // if not simulator
        let songs = MPMediaQuery.songsQuery().items
        audioUrl = songs!.first!.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
#else
        audioUrl = NSURL(fileURLWithPath: Constant.Path.DummyAudio)
#endif
    }
    
    override func tearDown() {
        super.tearDown()
        
        musicPlayer = nil
        musicPlayerExpectation = nil
        audioPlayerExpectation = nil
        trackManagerExpectation = nil
        musicPlayerDelegateErrorExpectation = nil
        musicPlayerDelegateStateExpectation = nil
        musicPlayerDelegateTimeExpectation = nil
        analyticsExpectation = nil
        expectedError = nil
        expectedState = nil
        expectedPlaybackTime = nil
        expectedPlaybackTimeRough = nil
        methodOrder = nil
        mockPlaylist = nil
        Analytics.__shared = Analytics()
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
                    musicPlayerExpectation!.fulfill()
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
                    musicPlayerExpectation!.fulfill()
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
        - delegate call
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.play()")
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")

        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool {
                audioPlayerExpectation!.fulfill()
                return true
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.Playing
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayNoTracks() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 0 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        expectedError = MusicPlayer.Error.NoMusic
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayInvalidPlayer() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockMediaItem: MPMediaItem {
            override var artist: String { return "" }
            override var title: String { return "" }
            override var playbackDuration: NSTimeInterval { return 219 }
            override var artwork: MPMediaItemArtwork { return MPMediaItemArtwork() }
            override var assetURL: NSURL { return NSURL(string: "fakeUrl")! }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
            override var currentTrack: MPMediaItem {
                return MockMediaItem()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)

        expectedError = MusicPlayer.Error.PlayerInit
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayNilAssetUrl() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockMediaItem: MPMediaItem {
            override var artist: String { return "" }
            override var title: String { return "" }
            override var playbackDuration: NSTimeInterval { return 219 }
            override var artwork: MPMediaItemArtwork { return MPMediaItemArtwork() }
            override var assetURL: NSURL? { return nil }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
            override var currentTrack: MPMediaItem {
                return MockMediaItem()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        expectedError = MusicPlayer.Error.PlayerInit
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayAVError1() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func prepareToPlay() -> Bool { return false }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedError = MusicPlayer.Error.AVError
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayAVError2() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool { return false }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedError = MusicPlayer.Error.AVError
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayNoVolume() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var volume: Float { return 0.0 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)

        expectedError = MusicPlayer.Error.NoVolume
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPause() {
        /**
        expectations
        - audio pauses
        - delegate call
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.pause()")
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override func pause() {
                audioPlayerExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.Paused
        
        // runnable
        mockMusicPlayer.pause()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testTogglePlay() {
        /**
        expectations
        - audio plays
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.play()")
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override func play() -> Bool {
                audioPlayerExpectation!.fulfill()
                return true
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.Playing
        
        // runnable
        mockMusicPlayer.togglePlayPause()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testTogglePause() {
        /**
        expectations
        - audio pauses
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.pause()")
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override func pause() {
                audioPlayerExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.Paused
        
        // runnable
        mockMusicPlayer.togglePlayPause()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSeekForward() {
        /**
        expectations
        - audio seeks forward
        */
        let waitExpectation = expectationWithDescription("wait")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.Paused
        
        // runnable
        mockMusicPlayer.seekForwardStart()
        
        // tests
        performAfterDelay(1) { () -> Void in
            waitExpectation.fulfill()
            XCTAssert(mockMusicPlayer.time > 0)
        }
        waitForExpectationsWithTimeout(2, handler: { error in XCTAssertNil(error) })
    }
    
    func testSeekForwardAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectationWithDescription("Analytics.shared.sendTimedAppEvent(_, _, _)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendTimedAppEvent(event: String, fromDate: NSDate, toDate: NSDate) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        // runnable
        musicPlayer!.seekForwardStart()
        musicPlayer!.seekForwardEnd()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSeekBackward() {
        /**
         expectations
         - audio seeks backward
         */
        let waitExpectation = expectationWithDescription("wait")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.Paused
        
        let startTime = 10.0
        mockMusicPlayer.time = startTime
        
        // runnable
        mockMusicPlayer.seekBackwardStart()
        
        // tests
        performAfterDelay(1) { () -> Void in
            waitExpectation.fulfill()
            XCTAssert(mockMusicPlayer.time < startTime)
        }
        waitForExpectationsWithTimeout(2, handler: { error in XCTAssertNil(error) })
    }
    
    func testSeekBackwardAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectationWithDescription("Analytics.shared.sendTimedAppEvent(_, _, _)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendTimedAppEvent(event: String, fromDate: NSDate, toDate: NSDate) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        // runnable
        musicPlayer!.seekBackwardStart()
        musicPlayer!.seekBackwardEnd()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testStop() {
        /**
        expectations
        - audio stops
        - 2 delegate calls
        */
        audioPlayerExpectation = expectationWithDescription("audioPlayer.stop()")
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        musicPlayerDelegateTimeExpectation = expectationWithDescription("MusicPlayerDelegate.changedPlaybackTime(_, _)")

        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func stop() {
                audioPlayerExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.Stopped
        expectedPlaybackTime = 0.0
        
        // runnable
        mockMusicPlayer.stop()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPrevious() {
        /**
        expectations
        - track manager stops, cue's previous track, then plays
        */
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool {
                methodOrder!.append(2)
                return true
            }
            override private func stop() {
                methodOrder!.append(0)
            }
        }
        
        class MockTrackManager: TrackManager {
            override func cuePrevious() -> Bool {
                methodOrder!.append(1)
                return true
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = MockTrackManager()
        musicPlayer!.__trackManager = mockTrackManager
                
        // runnable
        musicPlayer!.previous()
        
        // tests
        XCTAssertMethodOrderCorrect(methodOrder!)
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
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = MockTrackManager()
        musicPlayer!.__trackManager = mockTrackManager
        
        expectedPlaybackTime = 0.0
        
        // runnable
        musicPlayer!.previous()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNext() {
        /**
        expectations
        - track manager stops, cue's next track, then plays
        */
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool {
                methodOrder!.append(2)
                return true
            }
            override private func stop() {
                methodOrder!.append(0)
            }
        }
        
        class MockTrackManager: TrackManager {
            override func cueNext() -> Bool {
                methodOrder!.append(1)
                return true
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = MockTrackManager()
        musicPlayer!.__trackManager = mockTrackManager
        
        // runnable
        musicPlayer!.next()
        
        // tests
        XCTAssertMethodOrderCorrect(methodOrder!)
    }
    
    func testNextFalse() {
        /**
         expectations
         - music player shouldn't play next track
         */
        let waitExpectation = expectationWithDescription("audioPlayer.play() shouldn't be called")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool {
                XCTFail()
                return false
            }
        }
        
        class MockTrackManager: TrackManager {
            override func cueNext() -> Bool { return false }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = MockTrackManager()
        musicPlayer!.__trackManager = mockTrackManager
        
        // runnable
        musicPlayer!.next()
        
        // tests
        performAfterDelay(1) { () -> (Void) in
            waitExpectation.fulfill()
        }
        waitForExpectationsWithTimeout(1, handler: { error in })
    }
    
    func testNextTrackPlaysAutomatically() {
        /**
         expectations
         - next track should be cued
         - next track should play
         */
        trackManagerExpectation = expectationWithDescription("trackManager.cueNext()")
        musicPlayerExpectation = expectationWithDescription("audioPlayer.play()")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool {
                musicPlayerExpectation!.fulfill()
                return true
            }
            
        }
        
        class MockTrackManager: TrackManager {
            override func cueNext() -> Bool {
                trackManagerExpectation!.fulfill()
                return super.cueNext()
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = MockTrackManager()
        mockTrackManager.__tracks = mockPlaylist!
        musicPlayer!.__trackManager = mockTrackManager
        
        // runnable
        mockAudioPlayer.playAtTime(218)
        
        // tests
        waitForExpectationsWithTimeout(3, handler: { error in })
    }
    
    func testPlayerTime() {
        /**
        expectations
        - audio player should skip to time
        - delegate call
        */
        musicPlayerDelegateTimeExpectation = expectationWithDescription("MusicPlayerDelegate.changedPlaybackTime(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override private func play() -> Bool { return true }
            override private func stop() { }
            override var currentTime: NSTimeInterval {
                set {
                    super.currentTime = newValue
                    XCTAssertEqual(expectedPlaybackTime, newValue)
                }
                get { return super.currentTime }
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        expectedPlaybackTime = 2.0
        
        // runnable
        musicPlayer!.time = expectedPlaybackTime!
        
        // tests
        XCTAssertEqual(expectedPlaybackTime, mockAudioPlayer.currentTime)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtStartRepeatModeNone() {
        /**
        expectations
        - track number increments
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.None

        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let expectedTrackNumber = musicPlayer!.currentTrackNumber + 1
        expectedState = MusicPlayer.State.Playing
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtEndRepeatModeNone() {
        /**
        expectations
        - track number resets
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.None

        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = TrackManager()
        mockTrackManager.__tracks = mockPlaylist!
        mockTrackManager.__trackIndex = mockPlaylist!.count - 1
        musicPlayer!.__trackManager = mockTrackManager
        
        let expectedTrackNumber = 0
        expectedState = MusicPlayer.State.Finished
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtEndRepeatModeOne() {
        /**
        expectations
        - track number stays the same
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.One

        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = TrackManager()
        mockTrackManager.__tracks = mockPlaylist!
        mockTrackManager.__trackIndex = mockPlaylist!.count - 1
        musicPlayer!.__trackManager = mockTrackManager
        
        let expectedTrackNumber = musicPlayer!.currentTrackNumber
        expectedState = MusicPlayer.State.Playing
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtStartRepeatModeAll() {
        /**
        expectations
        - track number increments
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.All

        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let expectedTrackNumber = musicPlayer!.currentTrackNumber + 1
        expectedState = MusicPlayer.State.Playing
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtEndRepeatModeAll() {
        /**
        expectations
        - track number resets
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectationWithDescription("MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.All

        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = TrackManager()
        mockTrackManager.__tracks = mockPlaylist!
        mockTrackManager.__trackIndex = mockPlaylist!.count - 1
        musicPlayer!.__trackManager = mockTrackManager
        
        let expectedTrackNumber = 0
        expectedState = MusicPlayer.State.Playing
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingFailure() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        expectedError = MusicPlayer.Error.AVError
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: false)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDecodeError() {
        /**
        expectations
        - analytics triggered
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectationWithDescription("MusicPlayerDelegate.threwError(_, _)")
        analyticsExpectation = expectationWithDescription("Analytics.shared.sendErrorEvent(_, _)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendErrorEvent(error: NSError, classId: String) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockError = NSError(domain: "", code: 0, userInfo: nil)
        
        expectedError = MusicPlayer.Error.Decode
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDecodeErrorDidOccur!(mockAudioPlayer, error: mockError)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlaybackTimerCallback() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateTimeExpectation = expectationWithDescription("MusicPlayerDelegate.changedPlaybackTime(_, _)")
        
        // mocks
        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        expectedPlaybackTimeRough = 1
        
        // runnable
        musicPlayer!.play()
        
        // tests
        waitForExpectationsWithTimeout(2, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlaybackTimerGetsInvalidated() {
        /**
        expectations
        - timer should be invalidated
        */
        musicPlayerExpectation = expectationWithDescription("musicPlayer.playbackCheckTimer.invalidate()")
        
        // mocks
        let mockAudioPlayer = try! AVAudioPlayer(contentsOfURL: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        class MockTimer: NSTimer {
            private override func invalidate() {
                musicPlayerExpectation!.fulfill()
            }
        }
        
        let mockPlaybackCheckTimer = MockTimer()
        musicPlayer!.__playbackCheckTimer = mockPlaybackCheckTimer
        
        // runnable
        musicPlayer!.stop()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ScrobbleViewDelegate

extension MusicPlayerTests: MusicPlayerDelegate {
    func threwError(sender: EasyMusic.MusicPlayer, error: EasyMusic.MusicPlayer.Error) {
        if expectedError != nil && expectedError == error {
            musicPlayerDelegateErrorExpectation!.fulfill()
        }
    }
    
    func changedState(sender: EasyMusic.MusicPlayer, state: EasyMusic.MusicPlayer.State) {
        if expectedState != nil && expectedState == state {
            musicPlayerDelegateStateExpectation!.fulfill()
        }
    }
    
    func changedPlaybackTime(sender: EasyMusic.MusicPlayer, playbackTime: NSTimeInterval) {
        if expectedPlaybackTimeRough != nil && fabs(expectedPlaybackTimeRough! - playbackTime) < 0.2 {
            musicPlayerDelegateTimeExpectation!.fulfill()
        } else if expectedPlaybackTime != nil && expectedPlaybackTime == playbackTime {
            musicPlayerDelegateTimeExpectation!.fulfill()
        }
    }
}