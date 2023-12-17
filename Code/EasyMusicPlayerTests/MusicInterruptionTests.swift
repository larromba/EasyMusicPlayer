import AVFoundation
@testable import EasyMusicPlayer
import XCTest

final class MusicInterruptionTests: XCTestCase {
    private var interruptionHandler: MusicInterruptionHandler!
    private var session: AudioSessionMock!
    private var previous: AudioSessionRouteDescriptionMock!

    override func setUpWithError() throws {
        session = AudioSessionMock()
        previous = AudioSessionRouteDescriptionMock()
        interruptionHandler = MusicInterruptionHandler(session: session)
    }

    override func tearDownWithError() throws {
        interruptionHandler = nil
        session = nil
        previous = nil
    }

    func test_interruption_whenStarted_expectMusicPaused() {
        let expectation = expectation(description: "wait for interruption to begin")
       
        // interrupt
        interruptionHandler.isPlaying = true
        interruptionHandler.callback = {
            XCTAssertEqual($0, .pause)
            expectation.fulfill()
        }
        interrupt()
      
        waitForExpectations(timeout: 1)
    }

    func test_interruption_whenEnded_expectMusicPlayed() {
        let expectation = expectation(description: "wait for callback")
     
        // interrupt
        interruptionHandler.isPlaying = true
        interrupt()
        waitSync()

        // uninterrupt
        interruptionHandler.isPlaying = false
        interruptionHandler.callback = {
            XCTAssertEqual($0, .play)
            expectation.fulfill()
        }
        uninterrupt()
   
        waitForExpectations(timeout: 1)
    }

    func test_interruption_whenHeadphonesRemoved_expectPausesMusic() {
        let expectation = expectation(description: "wait for interruption to begin")
        
        // interrupt
        interruptionHandler.isPlaying = true
        interruptionHandler.callback = {
            XCTAssertEqual($0, .pause)
            expectation.fulfill()
        }
        removeHeadphones()
       
        waitForExpectations(timeout: 1)
    }

    func test_interruption_whenHeadphonesReattached_expectPlaysMusic() {
        let expectation = expectation(description: "wait for callback")
        
        // remove headphones
        interruptionHandler.isPlaying = true
        removeHeadphones()
        waitSync()

        // attach headphones
        interruptionHandler.isPlaying = false
        interruptionHandler.callback = {
            XCTAssertEqual($0, .play)
            expectation.fulfill()
        }
        attachHeadphones()

        waitForExpectations(timeout: 1)
    }

    func test_interruption_whenStoppedAndHeadphonesReattached_expectDoesNotPlayMusic() {
        // remove headphones
        interruptionHandler.isPlaying = false
        removeHeadphones()
        waitSync()

        // attach headphones
        interruptionHandler.callback = { _ in
            XCTFail("shouldn't be called")
        }
        attachHeadphones()
        waitSync()
    }

    func test_interruption_whenDifferentOutputReattached_expectDoesNotPlayMusic() {
        // remove headphones
        interruptionHandler.isPlaying = true
        removeHeadphones()
        waitSync()

        // attach different headphones
        interruptionHandler.isPlaying = false
        interruptionHandler.callback = { _ in
            XCTFail("shouldn't be called")
        }
        attachBluetoothHeadphones()
        waitSync()
    }

    func test_interruption_whenHeadphonesRemovedAndReattachedBeforeInterruptionFinishes_expectDoesNotTakePriority() {
        let expectation = expectation(description: "wait for callback")

        // remove headphones
        interruptionHandler.isPlaying = true
        removeHeadphones()
        waitSync()

        // interrupt
        interruptionHandler.isPlaying = false
        interruptionHandler.callback = { _ in
            XCTFail("shouldn't be called")
        }
        interrupt()
        waitSync()

        // attach headphones
        attachHeadphones()
        waitSync()

        // interrupt
        interruptionHandler.callback = {
            XCTAssertEqual($0, .play)
            expectation.fulfill()
        }
        uninterrupt()

        waitForExpectations(timeout: 3)
    }

    func test_interruption_whenBeforeHeadphonesRemovedAndReattached_expectDoesNotTakePriority() {
        let expectation = expectation(description: "wait for callback")

        // interrupt
        interruptionHandler.isPlaying = true
        interrupt()
        waitSync()

        // remove headphones
        interruptionHandler.isPlaying = false
        interruptionHandler.callback = { _ in
            XCTFail("shouldn't be called")
        }
        removeHeadphones()
        waitSync()

        // uninterrupt
        uninterrupt()
        waitSync()

        // attach headphones
        interruptionHandler.callback = {
            XCTAssertEqual($0, .play)
            expectation.fulfill()
        }
        attachHeadphones()

        waitForExpectations(timeout: 3)
    }

    private func interrupt() {
        let code = AVAudioSession.InterruptionType.began.rawValue
        let notification = Notification(
            name: AVAudioSession.interruptionNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                AVAudioSessionInterruptionReasonKey: NSNumber(value: 0)
            ]
        )
        NotificationCenter.default.post(notification)
    }

    private func uninterrupt() {
        let code = AVAudioSession.InterruptionType.ended.rawValue
        let notification = Notification(
            name: AVAudioSession.interruptionNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                AVAudioSessionInterruptionReasonKey: NSNumber(value: 0)
            ]
        )
        NotificationCenter.default.post(notification)
    }

    private func removeHeadphones() {
        previous.outputRoutes = [AVAudioSession.Port.headphones]
        session.outputRoutes = [AVAudioSession.Port.builtInSpeaker]
        let code = AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionRouteChangeReasonKey: NSNumber(value: code),
                AVAudioSessionRouteChangePreviousRouteKey: previous!
            ]
        )
        NotificationCenter.default.post(notification)
    }

    private func attachHeadphones() {
        session.outputRoutes = [AVAudioSession.Port.headphones]
        let code = AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionRouteChangeReasonKey: NSNumber(value: code),
                AVAudioSessionRouteChangePreviousRouteKey: previous!
            ]
        )
        NotificationCenter.default.post(notification)
        previous.outputRoutes = [AVAudioSession.Port.headphones]
    }

    private func attachBluetoothHeadphones() {
        session.outputRoutes = [AVAudioSession.Port.bluetoothA2DP]
        let code = AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionRouteChangeReasonKey: NSNumber(value: code),
                AVAudioSessionRouteChangePreviousRouteKey: previous!
            ]
        )
        NotificationCenter.default.post(notification)
    }
}
