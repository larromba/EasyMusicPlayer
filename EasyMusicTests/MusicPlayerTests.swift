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
private var expectedError: EasyMusic.MusicPlayer.MusicError?
private var expectedState: EasyMusic.MusicPlayer.State?
private var expectedPlaybackTime: TimeInterval?
private var expectedPlaybackTimeRough: TimeInterval?
private var methodOrder: [Int]?
private var audioUrl: URL!

class MusicPlayerTests: XCTestCase {
    fileprivate var musicPlayer: EasyMusic.MusicPlayer?
    fileprivate var mockPlaylist: [MPMediaItem]?

    override func setUp() {
        super.setUp()
        
        musicPlayer = MusicPlayer(delegate: self)
        methodOrder = []
        
        class MockMediaItem: MPMediaItem {
            override var artist: String { return "artist" }
            override var title: String { return "title" }
            override var playbackDuration: TimeInterval { return 9.0 }
            override var artwork: MPMediaItemArtwork { return MPMediaItemArtwork(image: UIImage()) }
            override var assetURL: URL { return URL(fileURLWithPath: Constant.Path.DummyAudio) }
        }

        mockPlaylist = [
            MockMediaItem(),
            MockMediaItem(),
            MockMediaItem()]
        
#if !((arch(i386) || arch(x86_64)) && os(iOS)) // if not simulator
        let songs = MPMediaQuery.songsQuery().items
        audioUrl = songs!.first!.valueForProperty(MPMediaItemPropertyAssetURL) as! NSURL
#else
        audioUrl = URL(fileURLWithPath: Constant.Path.DummyAudio)
#endif
    }
    
    override func tearDown() {
        super.tearDown()
        
        NotificationCenter.default.removeObserver(musicPlayer!)
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
        musicPlayerExpectation = expectation(description: "musicPlayer.enableAudioSession(_)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func enableAudioSession(_ enable: Bool) {
                if enable == true {
                    musicPlayerExpectation!.fulfill()
                }
            }
        }
        
        // runnable
        _ = MockMusicPlayer(delegate: self)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioSessionOnDeinit() {
        /**
        expectations
        - enableAudioSession should be set to false on deinit
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.enableAudioSession(_)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func enableAudioSession(_ enable: Bool) {
                if enable == false {
                    musicPlayerExpectation!.fulfill()
                }
            }
        }
        
        // runnable
        _ = MockMusicPlayer(delegate: self)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlay() {
        /**
        expectations
        - audio plays
        - delegate call
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.play()")
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")

        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool {
                audioPlayerExpectation!.fulfill()
                return true
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.playing
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayNoTracks() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectation(description: "MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 0 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        expectedError = MusicPlayer.MusicError.noMusic
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayInvalidPlayer() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectation(description: "MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockMediaItem: MPMediaItem {
            override var artist: String { return "" }
            override var title: String { return "" }
            override var playbackDuration: TimeInterval { return 219 }
            override var artwork: MPMediaItemArtwork { return MPMediaItemArtwork(image: UIImage()) }
            override var assetURL: URL { return URL(string: "fakeUrl")! }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
            override var currentTrack: MPMediaItem {
                return MockMediaItem()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)

        expectedError = MusicPlayer.MusicError.playerInit
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayNilAssetUrl() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectation(description: "MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockMediaItem: MPMediaItem {
            override var artist: String { return "" }
            override var title: String { return "" }
            override var playbackDuration: TimeInterval { return 219 }
            override var artwork: MPMediaItemArtwork { return MPMediaItemArtwork(image: UIImage()) }
            override var assetURL: URL? { return nil }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
            override var currentTrack: MPMediaItem {
                return MockMediaItem()
            }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        expectedError = MusicPlayer.MusicError.playerInit
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayAVError1() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectation(description: "MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func prepareToPlay() -> Bool { return false }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedError = MusicPlayer.MusicError.avError
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayAVError2() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectation(description: "MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool { return false }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedError = MusicPlayer.MusicError.avError
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayNoVolume() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectation(description: "MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var volume: Float { return 0.0 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)

        expectedError = MusicPlayer.MusicError.noVolume
        
        // runnable
        mockMusicPlayer.play()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testTogglePlay() {
        /**
        expectations
        - audio plays
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.play()")
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        
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
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.playing
        
        // runnable
        mockMusicPlayer.togglePlayPause()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlayAudioSessionUninterrupted() {
        /**
        expectations
        - audio plays
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.play()")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool {
                audioPlayerExpectation!.fulfill()
                return true
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        mockMusicPlayer.__isAudioSessionInterrupted = true
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        let mockUserInfo: [AnyHashable: Any] = [
            AVAudioSessionInterruptionTypeKey : AVAudioSessionInterruptionType.ended.rawValue
        ]
        let mockNotification = Notification(name: NSNotification.Name.AVAudioSessionInterruption, object: nil, userInfo: mockUserInfo)
        
        // runnable
        NotificationCenter.default.post(mockNotification)
                
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPause() {
        /**
        expectations
        - audio pauses
        - delegate call
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.pause()")
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        
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
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.paused
        
        // runnable
        mockMusicPlayer.pause()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testTogglePause() {
        /**
        expectations
        - audio pauses
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.pause()")
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        
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
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.paused
        
        // runnable
        mockMusicPlayer.togglePlayPause()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPauseAudioSessionInterruptedWhenPlayingInForeground() {
        /**
        expectations
        - audio pauses
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.pause()")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func pause() {
                audioPlayerExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        let mockUserInfo: [AnyHashable: Any] = [
            AVAudioSessionInterruptionTypeKey : AVAudioSessionInterruptionType.began.rawValue
        ]
        let mockNotification = Notification(name: NSNotification.Name.AVAudioSessionInterruption, object: nil, userInfo: mockUserInfo)
        
        // runnable
        NotificationCenter.default.post(mockNotification)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPauseAudioSessionInterruptedWhenPlayingInBackground() {
        /**
        expectations
        - audio pauses
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.pause()")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func pause() {
                audioPlayerExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        mockMusicPlayer.__isPlayingInBackground = true

        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        let mockUserInfo: [AnyHashable: Any] = [
            AVAudioSessionInterruptionTypeKey : AVAudioSessionInterruptionType.began.rawValue
        ]
        let mockNotification = Notification(name: NSNotification.Name.AVAudioSessionInterruption, object: nil, userInfo: mockUserInfo)
        
        // runnable
        NotificationCenter.default.post(mockNotification)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSeekForward() {
        /**
        expectations
        - audio seeks forward
        */
        let waitExpectation = expectation(description: "wait")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.paused
        
        // runnable
        mockMusicPlayer.seekForwardStart()
        
        // tests
        performAfterDelay(1) { () -> Void in
            waitExpectation.fulfill()
            XCTAssert(mockMusicPlayer.time > 0)
        }
        waitForExpectations(timeout: 2, handler: { error in XCTAssertNil(error) })
    }
    
    func testSeekForwardAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectation(description: "Analytics.shared.sendTimedAppEvent(_, _, _)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendTimedAppEvent(_ event: String, fromDate: Date, toDate: Date) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        // runnable
        musicPlayer!.seekForwardStart()
        musicPlayer!.seekForwardEnd()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSeekBackward() {
        /**
         expectations
         - audio seeks backward
         */
        let waitExpectation = expectation(description: "wait")
        
        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.paused
        
        let startTime = 10.0
        mockMusicPlayer.time = startTime
        
        // runnable
        mockMusicPlayer.seekBackwardStart()
        
        // tests
        performAfterDelay(1) { () -> Void in
            waitExpectation.fulfill()
            XCTAssert(mockMusicPlayer.time < startTime)
        }
        waitForExpectations(timeout: 2, handler: { error in XCTAssertNil(error) })
    }
    
    func testSeekBackwardAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectation(description: "Analytics.shared.sendTimedAppEvent(_, _, _)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendTimedAppEvent(_ event: String, fromDate: Date, toDate: Date) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        // runnable
        musicPlayer!.seekBackwardStart()
        musicPlayer!.seekBackwardEnd()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testStop() {
        /**
        expectations
        - audio stops
        - 2 delegate calls
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.stop()")
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        musicPlayerDelegateTimeExpectation = expectation(description: "MusicPlayerDelegate.changedPlaybackTime(_, _)")

        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func stop() {
                audioPlayerExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        expectedState = MusicPlayer.State.stopped
        expectedPlaybackTime = 0.0
        
        // runnable
        mockMusicPlayer.stop()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testStopHeadphonesRemoved() {
        /**
        expectations
        - audio pauses
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.pause()")

        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func pause() {
                audioPlayerExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        let mockUserInfo: [AnyHashable: Any] = [
            AVAudioSessionRouteChangeReasonKey : AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue
        ]
        let mockNotification = Notification(name: NSNotification.Name.AVAudioSessionRouteChange, object: nil, userInfo: mockUserInfo)
        
        // runnable
        NotificationCenter.default.post(mockNotification)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testStopHeadphonesAttached() {
        /**
        expectations
        - audio pauses
        */
        audioPlayerExpectation = expectation(description: "audioPlayer.pause()")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func pause() {
                audioPlayerExpectation!.fulfill()
            }
        }
        
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override var numOfTracks: Int { return 1 }
        }
        
        let mockMusicPlayer = MockMusicPlayer(delegate: self)
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = mockMusicPlayer
        mockMusicPlayer.__player = mockAudioPlayer
        
        let mockUserInfo: [AnyHashable: Any] = [
            AVAudioSessionRouteChangeReasonKey : AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue
        ]
        let mockNotification = Notification(name: NSNotification.Name.AVAudioSessionRouteChange, object: nil, userInfo: mockUserInfo)
        
        // runnable
        NotificationCenter.default.post(mockNotification)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPrevious() {
        /**
        expectations
        - track manager stops, cue's previous track, then plays
        */
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool {
                methodOrder!.append(2)
                return true
            }
            override fileprivate func stop() {
                methodOrder!.append(0)
            }
        }
        
        class MockTrackManager: TrackManager {
            override func cuePrevious() -> Bool {
                methodOrder!.append(1)
                return true
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
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
        musicPlayerDelegateTimeExpectation = expectation(description: "MusicPlayerDelegate.changedPlaybackTime(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool { return true }
            override fileprivate func stop() { }
        }
        
        class MockTrackManager: TrackManager {
            override func cuePrevious() -> Bool { return false }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = MockTrackManager()
        musicPlayer!.__trackManager = mockTrackManager
        
        expectedPlaybackTime = 0.0
        
        // runnable
        musicPlayer!.previous()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testNext() {
        /**
        expectations
        - track manager stops, cue's next track, then plays
        */
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool {
                methodOrder!.append(2)
                return true
            }
            override fileprivate func stop() {
                methodOrder!.append(0)
            }
        }
        
        class MockTrackManager: TrackManager {
            override func cueNext() -> Bool {
                methodOrder!.append(1)
                return true
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
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
        let waitExpectation = expectation(description: "audioPlayer.play() shouldn't be called")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool {
                XCTFail()
                return false
            }
        }
        
        class MockTrackManager: TrackManager {
            override func cueNext() -> Bool { return false }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
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
        waitForExpectations(timeout: 2, handler: { error in })
    }
    
    func testNextTrackPlaysAutomatically() {
        /**
         expectations
         - next track should be cued
         - next track should play
         */
        trackManagerExpectation = expectation(description: "trackManager.cueNext()")
        musicPlayerExpectation = expectation(description: "audioPlayer.play()")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool {
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
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = MockTrackManager()
        mockTrackManager.__tracks = mockPlaylist!
        musicPlayer!.__trackManager = mockTrackManager
        
        // runnable
        mockAudioPlayer.play(atTime: 218)
        
        // tests
        waitForExpectations(timeout: 3, handler: { error in })
    }
    
    func testPlayerTime() {
        /**
        expectations
        - audio player should skip to time
        - delegate call
        */
        musicPlayerDelegateTimeExpectation = expectation(description: "MusicPlayerDelegate.changedPlaybackTime(_, _)")
        
        // mocks
        class MockAudioPlayer: AVAudioPlayer {
            override fileprivate func play() -> Bool { return true }
            override fileprivate func stop() { }
            override var currentTime: TimeInterval {
                set {
                    super.currentTime = newValue
                    XCTAssertEqual(expectedPlaybackTime, newValue)
                }
                get { return super.currentTime }
            }
        }
        
        let mockAudioPlayer = try! MockAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        expectedPlaybackTime = 2.0
        
        // runnable
        musicPlayer!.time = expectedPlaybackTime!
        
        // tests
        XCTAssertEqual(expectedPlaybackTime, mockAudioPlayer.currentTime)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtStartRepeatModeNone() {
        /**
        expectations
        - track number increments
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.none

        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let expectedTrackNumber = musicPlayer!.currentTrackNumber + 1
        expectedState = MusicPlayer.State.playing
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtEndRepeatModeNone() {
        /**
        expectations
        - track number resets
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.none

        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = TrackManager()
        mockTrackManager.__tracks = mockPlaylist!
        mockTrackManager.__trackIndex = mockPlaylist!.count - 1
        musicPlayer!.__trackManager = mockTrackManager
        
        let expectedTrackNumber = 0
        expectedState = MusicPlayer.State.finished
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtEndRepeatModeOne() {
        /**
        expectations
        - track number stays the same
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.one

        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = TrackManager()
        mockTrackManager.__tracks = mockPlaylist!
        mockTrackManager.__trackIndex = mockPlaylist!.count - 1
        musicPlayer!.__trackManager = mockTrackManager
        
        let expectedTrackNumber = musicPlayer!.currentTrackNumber
        expectedState = MusicPlayer.State.playing
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtStartRepeatModeAll() {
        /**
        expectations
        - track number increments
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.all

        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let expectedTrackNumber = musicPlayer!.currentTrackNumber + 1
        expectedState = MusicPlayer.State.playing
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingAtEndRepeatModeAll() {
        /**
        expectations
        - track number resets
        - delegate call
        */
        musicPlayerDelegateStateExpectation = expectation(description: "MusicPlayerDelegate.changedState(_, _)")
        
        // mocks
        musicPlayer!.repeatMode = MusicPlayer.RepeatMode.all

        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockTrackManager = TrackManager()
        mockTrackManager.__tracks = mockPlaylist!
        mockTrackManager.__trackIndex = mockPlaylist!.count - 1
        musicPlayer!.__trackManager = mockTrackManager
        
        let expectedTrackNumber = 0
        expectedState = MusicPlayer.State.playing
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: true)
        
        // tests
        XCTAssertEqual(musicPlayer!.currentTrackNumber, expectedTrackNumber)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDidFinishPlayingFailure() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectation(description: "MusicPlayerDelegate.threwError(_, _)")
        
        // mocks
        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        expectedError = MusicPlayer.MusicError.avError
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDidFinishPlaying!(mockAudioPlayer, successfully: false)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAudioPlayerDecodeError() {
        /**
        expectations
        - analytics triggered
        - delegate call
        */
        musicPlayerDelegateErrorExpectation = expectation(description: "MusicPlayerDelegate.threwError(_, _)")
        analyticsExpectation = expectation(description: "Analytics.shared.sendErrorEvent(_, _)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendErrorEvent(_ error: Error, classId: String) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        let mockError = NSError(domain: "", code: 0, userInfo: nil)
        
        expectedError = MusicPlayer.MusicError.decode
        
        // runnable
        mockAudioPlayer.delegate?.audioPlayerDecodeErrorDidOccur!(mockAudioPlayer, error: mockError)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlaybackTimerCallback() {
        /**
        expectations
        - delegate call
        */
        musicPlayerDelegateTimeExpectation = expectation(description: "MusicPlayerDelegate.changedPlaybackTime(_, _)")
        
        // mocks
        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        expectedPlaybackTimeRough = 1
        
        // runnable
        musicPlayer!.play()
        
        // tests
        waitForExpectations(timeout: 2, handler: { error in XCTAssertNil(error) })
    }
    
    func testPlaybackTimerGetsInvalidated() {
        /**
        expectations
        - timer should be invalidated
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.playbackCheckTimer.invalidate()")
        
        // mocks
        let mockAudioPlayer = try! AVAudioPlayer(contentsOf: audioUrl)
        mockAudioPlayer.delegate = musicPlayer
        musicPlayer!.__player = mockAudioPlayer
        
        class MockTimer: Timer {
            fileprivate override func invalidate() {
                musicPlayerExpectation!.fulfill()
            }
        }
        
        let mockPlaybackCheckTimer = MockTimer()
        musicPlayer!.__playbackCheckTimer = mockPlaybackCheckTimer
        
        // runnable
        musicPlayer!.stop()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ScrubberViewDelegate

extension MusicPlayerTests: MusicPlayerDelegate {
    func threwError(_ sender: EasyMusic.MusicPlayer, error: EasyMusic.MusicPlayer.MusicError) {
        if expectedError != nil && expectedError == error {
            musicPlayerDelegateErrorExpectation!.fulfill()
        }
    }
    
    func changedState(_ sender: EasyMusic.MusicPlayer, state: EasyMusic.MusicPlayer.State) {
        if expectedState != nil && expectedState == state {
            musicPlayerDelegateStateExpectation!.fulfill()
        }
    }
    
    func changedPlaybackTime(_ sender: EasyMusic.MusicPlayer, playbackTime: TimeInterval) {
        if expectedPlaybackTimeRough != nil && fabs(expectedPlaybackTimeRough! - playbackTime) < 0.2 {
            musicPlayerDelegateTimeExpectation!.fulfill()
        } else if expectedPlaybackTime != nil && expectedPlaybackTime == playbackTime {
            musicPlayerDelegateTimeExpectation!.fulfill()
        }
    }
}
