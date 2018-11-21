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
        UIApplication.shared.keyWindow!.rootViewController = playerViewController
    }

    override func tearDown() {
        NotificationCenter.default.removeObserver(playerViewController!)
        playerViewController = nil
        musicPlayerExpectation = nil
        infoViewExpectation = nil
        controlsViewExpectation = nil
        shareManagerExpectation = nil
        analyticsExpectation = nil
        Analytics.__shared = Analytics()

        super.tearDown()
    }

    func testScreenAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectation(description: "analytics.sendScreenNameEvent(_)")

        // mocks
        class MockAnalytics: Analytics {
            override func sendScreenNameEvent(_ classId: Any) {
                analyticsExpectation!.fulfill()
            }
        }

        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics

        // runnable
        playerViewController!.viewDidAppear(false)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testAlertAnalytics() {
        /**
         expectations
         - analytics event sent
         */
        analyticsExpectation = expectation(description: "analytics.sendAlertEvent(_)")

        // mocks
        class MockAnalytics: Analytics {
            override func sendAlertEvent(_ event: String, classId: Any) {
                analyticsExpectation!.fulfill()
            }
        }

        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics

        // runnable
        playerViewController!.threwError(playerViewController!.__musicPlayer, error: .noMusic)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testPlay() {
        /**
        expectations
        - Music player attempts to play
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.play()")
        analyticsExpectation = expectation(description: "analytics.sendButtonPressEvent(_, _)")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func play() {
                musicPlayerExpectation!.fulfill()
            }
        }

        class MockAnalytics: Analytics {
            override func sendButtonPressEvent(_ event: String, classId: Any) {
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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testPlaying() {
        /**
        expectations
        - Info view updates
        - Controls are in playing state
        - Scrubber view is enabled
        */
        infoViewExpectation = expectation(description: "infoView.setInfoFromTrack(_)")
        controlsViewExpectation = expectation(description: "controlsView.setControlsPlaying()")

        // mocks
        class MockInfoView: InfoView {
            var setInfoFromTrack: Bool = false
            var setTrackPosition: Bool = false
            override var classForCoder: AnyClass { return InfoView.self }
            override func setInfoFromTrack(_ track: Track) {
                setInfoFromTrack = true
                checkExpectation()
            }
            override func setTrackPosition(_ trackPosition: Int, totalTracks: Int) {
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
            override var classForCoder: AnyClass { return ControlsView.self }
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

        playerViewController!.__scrubberView.isUserInteractionEnabled = false

        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.playing)

        // tests
        XCTAssertTrue(playerViewController!.__scrubberView.isUserInteractionEnabled)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testControlsStateAfterEnteringExitingApp1() {
        /**
        expectations
        - controls are in stopped state
            -- leaving app whilst audio is playing
            -- audio stops
            -- entering app and audio has stopped
        */
        controlsViewExpectation = expectation(description: "controlsView.setControlsStopped()")

        // mocks
        class MockControlsView: ControlsView {
            override var classForCoder: AnyClass { return ControlsView.self }
            override func setControlsStopped() {
                controlsViewExpectation!.fulfill()
            }
        }

        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool {
                return _isPlaying
            }
        }

        class MockAudioPlayer: AVAudioPlayer {
            override var isPlaying: Bool { return false }
            override func stop() { }
            override var currentTime: TimeInterval {
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
        var notification = Notification(name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.post(notification)

        _isPlaying = false
        notification = Notification(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.post(notification)

        // tests
        XCTAssertFalse(playerViewController!.__scrubberView.isUserInteractionEnabled)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testAudioStopsOnEnteringAppAndThingsWentHorriblyWrong() {
        /**
        expectations
        - audio stops
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.stop()")

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
        let notification = Notification(name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.post(notification)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testNoMusicErrorIsThrown() {
        /**
         expectations
         - error alert is thrown
         */

        // mocks
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)

        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayer.MusicError.noMusic)

        // tests
        XCTAssertTrue(playerViewController!.presentedViewController is UIAlertController)
    }

    func testNoMusicErrorClearsInfo() {
        infoViewExpectation = expectation(description: "infoView.clearInfo()")

        /**
         expectations
         - error alert is thrown
         */

        // mocks
        class MockInfoView: InfoView {
            override var classForCoder: AnyClass { return InfoView.self }
            override func clearInfo() {
                infoViewExpectation!.fulfill()
            }
        }
        let mockInfoView = MockInfoView()
        playerViewController!.__infoView = mockInfoView
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)

        // runnable
        playerViewController?.threwError(mockMusicPlayer, error: .noMusic)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testNoVolumeErrorIsThrown() {
        /**
         expectations
         - error alert is thrown
         */

         // mocks
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)

        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayer.MusicError.noVolume)

        // tests
        XCTAssertTrue(playerViewController!.presentedViewController is UIAlertController)
    }

    func testAuthorizationErrorIsThrown() {
        /**
         expectations
         - error alert is thrown
         */

        // mocks
        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)

        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayer.MusicError.authorization)

        // tests
        XCTAssertTrue(playerViewController!.presentedViewController is UIAlertController)
    }

    /**
     bug: pressing >> continuously locks up player
     investigation: logic state from generic error (avError / playerInit / decode)
     introduced: 1.1.2
     reporter: rs@apoplus.info
     date: 31/05/2017
     */
    func testPlayErrorGeneric() {
        /**
         expectations
         - track removed from track manager 
         - next track is played
         */
        musicPlayerExpectation = expectation(description: "musicPlayer.next()")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func next() {
                musicPlayerExpectation!.fulfill()
            }
        }

        let mockTrackManager = TrackManager()
        let mockItem = MPMediaItem()
        mockTrackManager.__tracks = [MPMediaItem(), mockItem, MPMediaItem()]
        mockTrackManager.__trackIndex = 1

        let mockMusicPlayer = MockMusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.trackManager = mockTrackManager

        // runnable
        mockMusicPlayer.delegate!.threwError(mockMusicPlayer, error: MusicPlayer.MusicError.decode)

        // tests
        XCTAssertFalse(mockTrackManager.__tracks.contains(where: { $0 === mockItem }))
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testPause() {
        /**
        expectations
        - Music player attempts to pause
        - Analytics event fired
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.pause()")
        analyticsExpectation = expectation(description: "analytics.sendButtonPressEvent(_, _)")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var isPlaying: Bool { return true }
            override func pause() {
                musicPlayerExpectation!.fulfill()
            }
        }

        class MockAnalytics: Analytics {
            override func sendButtonPressEvent(_ event: String, classId: Any) {
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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testPaused() {
        /**
        expectations
        - Controls are in paused state
        - Scrubber view is disabled
        */
        controlsViewExpectation = expectation(description: "controlsView.setControlsPaused()")

        // mocks
        class MockControlsView: ControlsView {
            override var classForCoder: AnyClass { return ControlsView.self }
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
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.paused)

        // tests
        XCTAssertFalse(playerViewController!.__scrubberView.isUserInteractionEnabled)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testNext() {
        /**
        expectations
        - Music player attempts next track
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.next()")

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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testNextDisabled() {
        /**
         expectations
         - button is disabled
         */

        // mocks
        class MockTrackManager: EasyMusic.TrackManager {
            override var numOfTracks: Int { return 1 }
        }

        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.trackManager = MockTrackManager()
        playerViewController!.__musicPlayer = mockMusicPlayer

        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.playing)

        // tests
        XCTAssertFalse(playerViewController!.__controlsView.nextButton.isEnabled)
    }

    func testNextRepeatAll() {
        /**
         expectations
         - button not disabled
         */

        // mocks
        class MockTrackManager: EasyMusic.TrackManager {
            override var numOfTracks: Int { return 1 }
        }

        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.repeatMode = MusicPlayer.RepeatMode.all
        mockMusicPlayer.trackManager = MockTrackManager()
        playerViewController!.__musicPlayer = mockMusicPlayer

        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.playing)

        // tests
        XCTAssertTrue(playerViewController!.__controlsView.nextButton.isEnabled)
    }

    func testPrevious() {
        /**
        expectations
        - Music player attempts previous track
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.previous()")

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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testPreviousDisabled() {
        /**
         expectations
         - button is disabled
         */

        // mocks
        class MockTrackManager: EasyMusic.TrackManager {
            override var numOfTracks: Int { return 1 }
        }

        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.trackManager = MockTrackManager()
        playerViewController!.__musicPlayer = mockMusicPlayer

        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.playing)

        // tests
        XCTAssertFalse(playerViewController!.__controlsView.prevButton.isEnabled)
    }

    func testPreviousRepeatAll() {
        /**
        expectations
        - button not disabled
        */

        // mocks
        class MockTrackManager: EasyMusic.TrackManager {
            override var numOfTracks: Int { return 1 }
        }

        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.trackManager = MockTrackManager()
        mockMusicPlayer.repeatMode = MusicPlayer.RepeatMode.all
        playerViewController!.__musicPlayer = mockMusicPlayer

        // runnable
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.playing)

        // tests
        XCTAssertTrue(playerViewController!.__controlsView.prevButton.isEnabled)
    }

    func testStop() {
        /**
        expectations
        - Music player attempts to stop
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.stop()")

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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testStopped() {
        /**
        expectations
        - Controls are in stopped state
        - Scrubber view is disabled
        */
        controlsViewExpectation = expectation(description: "controlsView.setControlsStopped()")

        // mocks
        class MockControlsView: ControlsView {
            override var classForCoder: AnyClass { return ControlsView.self }
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
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.stopped)

        // tests
        XCTAssertFalse(playerViewController!.__scrubberView.isUserInteractionEnabled)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testFinished() {
        /**
        expectations
        - Controls are in stopped state
        - Scrubber view is disabled
        - Info is cleared
        */
        controlsViewExpectation = expectation(description: "controlsView.setControlsStopped()")
        infoViewExpectation = expectation(description: "infoView.clearInfo()")

        // mocks
        class MockControlsView: ControlsView {
            override var classForCoder: AnyClass { return ControlsView.self }
            override func setControlsStopped() {
                controlsViewExpectation!.fulfill()
            }
        }

        class MockInfoView: InfoView {
            override var classForCoder: AnyClass { return InfoView.self }
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
        mockMusicPlayer.delegate!.changedState(mockMusicPlayer, state: MusicPlayer.State.finished)

        // tests
        XCTAssertFalse(playerViewController!.__scrubberView.isUserInteractionEnabled)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testShuffle() {
        /**
        expectations
        - Music player shuffles
        */
        musicPlayerExpectation = expectation(description: "musicPlayer.shuffle()")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override func stop() {}
            override func play() {}
            override func shuffle() {
                musicPlayerExpectation!.fulfill()
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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testShare() {
        /**
        expectations
        - track is shared
        */
        shareManagerExpectation = expectation(description: "shareManager.shareTrack(_, _)")

        // mocks
        class MockShareManager: ShareManager {
            override func shareTrack(_ track: Track, presenter: UIViewController, sender: UIView, completion: ((ShareManager.Result, String?) -> Void)?) {
                if sharedTrack == track {
                    shareManagerExpectation!.fulfill()
                }
            }
        }

        class MockTrackManager: EasyMusic.TrackManager {
            override var currentResolvedTrack: Track {
                sharedTrack = super.currentResolvedTrack
                return sharedTrack
            }
        }

        let mockShareManager = MockShareManager()
        playerViewController!.__shareManager = mockShareManager

        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.trackManager = MockTrackManager()
        playerViewController!.__musicPlayer = mockMusicPlayer

        let mockControlsView = ControlsView()
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController

        let mockButton = UIButton()

        // runnable
        mockControlsView.shareButtonPressed(mockButton)

        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testRepeat() {
        /**
        expectations
        - repeat mode changes
        */

        // mocks
        let mockControlsView = ControlsView()
        mockControlsView.repeatButton.setButtonState(RepeatButton.State.all)
        playerViewController!.__controlsView = mockControlsView
        mockControlsView.delegate = playerViewController

        let mockMusicPlayer = MusicPlayer(delegate: playerViewController!)
        mockMusicPlayer.repeatMode = MusicPlayer.RepeatMode.all
        playerViewController!.__musicPlayer = mockMusicPlayer

        let mockButton = RepeatButton()
        let expectedRepeatMode = MusicPlayer.RepeatMode.none

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
        let userData = UserData(userDefaults: UserDefaults(suiteName: "test")!)
        userData.repeatMode = MusicPlayer.RepeatMode.all
        playerViewController!.__userData = userData

        let expectedRepeatButtonState = RepeatButton.State.all

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
        infoViewExpectation = expectation(description: "infoView.setTime(_, _)")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var time: TimeInterval {
                set {}
                get { return 0.0 }
            }
        }

        class MockInfoView: InfoView {
            override var classForCoder: AnyClass { return InfoView.self }
            override func setTime(_ time: TimeInterval, duration: TimeInterval) {
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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }

    func testScrubberTouchEnded() {
        /**
        expectations
        - Music player attempts to scrub
        - Remote time set
        */
        infoViewExpectation = expectation(description: "infoView.setRemoteTime(_, _)")
        musicPlayerExpectation = expectation(description: "musicPlayer.time")

        // mocks
        class MockMusicPlayer: EasyMusic.MusicPlayer {
            override var time: TimeInterval {
                set { musicPlayerExpectation!.fulfill() }
                get { return 0.0 }
            }
        }

        class MockInfoView: InfoView {
            override var classForCoder: AnyClass { return InfoView.self }
            override func setRemoteTime(_ time: TimeInterval, duration: TimeInterval) {
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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}
