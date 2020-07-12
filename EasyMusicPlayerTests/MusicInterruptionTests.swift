import AVFoundation
@testable import EasyMusic
import TestExtensions
import XCTest

final class MusicInterruptionTests: XCTestCase {
    private var interruptionHandler: MusicInterruptionHandler!
    private var env: AppTestEnvironment!
    private var playerFactory: DummyAudioPlayerFactory!

    override func setUp() {
        super.setUp()
        interruptionHandler = MusicInterruptionHandler()
        playerFactory = DummyAudioPlayerFactory()
        env = AppTestEnvironment(interruptionHandler: interruptionHandler, playerFactory: playerFactory)
    }

    override func tearDown() {
        interruptionHandler = nil
        playerFactory = nil
        env = nil
        super.tearDown()
    }

    func test_interruption_whenStarted_expectMusicPaused() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        interrupt()

        // test
        waitSync()
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_interruption_whenEnded_expectMusicPlayed() {
        // mocks
        env.inject()
        env.setPlaying()
        playerFactory.audioPlayer?.invocations.clear()

        // sut
        interrupt()
        waitSync()
        uninterrupt()

        // test
        waitSync()
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_interruption_whenFromAppSuspension_expectIsIgnored() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        interruptFromSuspend()

        // test
        waitSync()
        XCTAssertFalse(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? true)
    }

    func test_interruption_whenHeadphonesRemoved_expectPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        removeHeadphones()

        // test
        waitSync()
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func test_interruption_whenHeadphonesReattached_expectPlaysMusic() {
        // mocks
        env.inject()
        env.setPlaying()
        playerFactory.audioPlayer?.invocations.clear()

        // sut
        removeHeadphones()
        waitSync()
        attachHeadphones()

        // test
        waitSync()
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_interruption_whenHeadphonesRemovedAndReattachedBeforeInterruptionFinishes_expectDoesNotTakePriority() {
        // mocks
        env.inject()
        env.setPlaying()
        playerFactory.audioPlayer?.invocations.clear()

        // sut
        removeHeadphones()
        interrupt()
        waitSync()
        attachHeadphones()

        // test
        waitSync()
        XCTAssertFalse(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? true)

        // sut
        uninterrupt()

        // test
        waitSync()
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func test_interruption_whenBeforeHeadphonesRemovedAndReattached_expectDoesNotTakePriority() {
        // mocks
        env.inject()
        env.setPlaying()
        playerFactory.audioPlayer?.invocations.clear()

        // sut
        interrupt()
        removeHeadphones()
        waitSync()
        uninterrupt()

        // test
        waitSync()
        XCTAssertFalse(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? true)

        // sut
        attachHeadphones()

        // test
        waitSync()
        XCTAssertTrue(playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    // MARK: - private

    private func interruptFromSuspend() {
        let code = AVAudioSession.InterruptionType.began.rawValue
        let notification = Notification(name: AVAudioSession.interruptionNotification, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                                                   AVAudioSessionInterruptionWasSuspendedKey: true])
        NotificationCenter.default.post(notification)
    }

    private func interrupt() {
        let code = AVAudioSession.InterruptionType.began.rawValue
        let notification = Notification(name: AVAudioSession.interruptionNotification, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                                                   AVAudioSessionInterruptionWasSuspendedKey: false])
        NotificationCenter.default.post(notification)
    }

    private func uninterrupt() {
        let code = AVAudioSession.InterruptionType.ended.rawValue
        let notification = Notification(name: AVAudioSession.interruptionNotification, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                                                   AVAudioSessionInterruptionWasSuspendedKey: false])
        NotificationCenter.default.post(notification)
    }

    private func removeHeadphones() {
        let code = AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue
        let notification = Notification(name: AVAudioSession.routeChangeNotification, object: nil,
                                        userInfo: [AVAudioSessionRouteChangeReasonKey: NSNumber(value: code)])
        NotificationCenter.default.post(notification)
    }

    private func attachHeadphones() {
        let code = AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue
        let notification = Notification(name: AVAudioSession.routeChangeNotification, object: nil,
                                        userInfo: [AVAudioSessionRouteChangeReasonKey: NSNumber(value: code)])
        NotificationCenter.default.post(notification)
    }
}
