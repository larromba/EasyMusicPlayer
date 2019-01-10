import AVFoundation
@testable import EasyMusic
import TestExtensions
import XCTest

final class MusicInterruptionTests: XCTestCase {
    private var interruptionHandler: MusicInterruptionHandler!
    private var env: AppTestEnvironment!

    override func setUp() {
        super.setUp()
        interruptionHandler = MusicInterruptionHandler()
        env = AppTestEnvironment(interruptionHandler: interruptionHandler)
    }

    override func tearDown() {
        interruptionHandler = nil
        env = nil
        super.tearDown()
    }

    func testInterruptionStartedPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        interrupt()

        // test
        waitSync()
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func testInterruptionEndedPlaysMusic() {
        // mocks
        env.inject()
        env.setPlaying()
        env.playerFactory.audioPlayer?.invocations.reset()

        // sut
        interrupt()
        waitSync()
        uninterrupt()

        // test
        waitSync()
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testInterruptionFromSuspendIsIgnored() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        interruptFromSuspend()

        // test
        waitSync()
        XCTAssertFalse(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? true)
    }

    func testHeadphonesRemovedPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        removeHeadphones()

        // test
        waitSync()
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
    }

    func testHeadphonesReattachedPlaysMusic() {
        // mocks
        env.inject()
        env.setPlaying()
        env.playerFactory.audioPlayer?.invocations.reset()

        // sut
        removeHeadphones()
        waitSync()
        attachHeadphones()

        // test
        waitSync()
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testHeadphonesRemovedAndReattachedBeforeInterruptionFinishesDoesNotTakePriority() {
        // mocks
        env.inject()
        env.setPlaying()
        env.playerFactory.audioPlayer?.invocations.reset()

        // sut
        removeHeadphones()
        interrupt()
        waitSync()
        attachHeadphones()

        // test
        waitSync()
        XCTAssertFalse(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? true)

        // sut
        uninterrupt()

        // test
        waitSync()
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    func testInterruptionBeforeHeadphonesRemovedAndReattachedDoesNotTakePriority() {
        // mocks
        env.inject()
        env.setPlaying()
        env.playerFactory.audioPlayer?.invocations.reset()

        // sut
        interrupt()
        removeHeadphones()
        waitSync()
        uninterrupt()

        // test
        waitSync()
        XCTAssertFalse(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? true)

        // sut
        attachHeadphones()

        // test
        waitSync()
        XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
    }

    // MARK: - private

    private func interruptFromSuspend() {
        let code = AVAudioSessionInterruptionType.began.rawValue
        let notification = Notification(name: .AVAudioSessionInterruption, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                                                   AVAudioSessionInterruptionWasSuspendedKey: true])
        NotificationCenter.default.post(notification)
    }

    private func interrupt() {
        let code = AVAudioSessionInterruptionType.began.rawValue
        let notification = Notification(name: .AVAudioSessionInterruption, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                                                   AVAudioSessionInterruptionWasSuspendedKey: false])
        NotificationCenter.default.post(notification)
    }

    private func uninterrupt() {
        let code = AVAudioSessionInterruptionType.ended.rawValue
        let notification = Notification(name: .AVAudioSessionInterruption, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                                                   AVAudioSessionInterruptionWasSuspendedKey: false])
        NotificationCenter.default.post(notification)
    }

    private func removeHeadphones() {
        let code = AVAudioSessionRouteChangeReason.oldDeviceUnavailable.rawValue
        let notification = Notification(name: .AVAudioSessionRouteChange, object: nil,
                                        userInfo: [AVAudioSessionRouteChangeReasonKey: NSNumber(value: code)])
        NotificationCenter.default.post(notification)
    }

    private func attachHeadphones() {
        let code = AVAudioSessionRouteChangeReason.newDeviceAvailable.rawValue
        let notification = Notification(name: .AVAudioSessionRouteChange, object: nil,
                                        userInfo: [AVAudioSessionRouteChangeReasonKey: NSNumber(value: code)])
        NotificationCenter.default.post(notification)
    }
}
