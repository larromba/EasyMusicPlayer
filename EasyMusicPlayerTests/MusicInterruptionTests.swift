import AVFoundation
@testable import EasyMusic
import TestExtensions
import XCTest

final class MusicInterruptionTests: XCTestCase {
    private var interruptionHandler: MusicInterruptionHandler!
    private var env: PlayerEnvironment!

    override func setUp() {
        super.setUp()
        interruptionHandler = MusicInterruptionHandler()
        env = PlayerEnvironment(interruptionHandler: interruptionHandler)
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
        wait(for: 0.5) {
            XCTAssertTrue(self.env.playerFactory.audioPlayer?.invocations
                .isInvoked(MockAudioPlayer.pause3.name) ?? false)
        }
    }

    func testInterruptionEndedPlaysMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        interrupt()
        uninterrupt()

        // test
        wait(for: 0.5) {
            XCTAssertTrue(self.env.playerFactory.audioPlayer?.invocations
                .isInvoked(MockAudioPlayer.play2.name) ?? false)
        }
    }

    func testHeadphonesRemovedPausesMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        removeHeadphones()

        // test
        wait(for: 0.5) {
            XCTAssertTrue(self.env.playerFactory.audioPlayer?.invocations
                .isInvoked(MockAudioPlayer.pause3.name) ?? false)
        }
    }

    func testHeadphonesReattachedPlaysMusic() {
        // mocks
        env.inject()
        env.setPlaying()

        // sut
        removeHeadphones()
        attachHeadphones()

        // test
        wait(for: 0.5) {
            XCTAssertTrue(self.env.playerFactory.audioPlayer?.invocations
                .isInvoked(MockAudioPlayer.play2.name) ?? false)
        }
    }

    // MARK: - private

    private func interrupt() {
        let code = AVAudioSessionInterruptionType.began.rawValue
        let notification = Notification(name: .AVAudioSessionInterruption, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: NSNumber(value: code)])
        NotificationCenter.default.post(notification)
    }

    private func uninterrupt() {
        let code = AVAudioSessionInterruptionType.ended.rawValue
        let notification = Notification(name: .AVAudioSessionInterruption, object: nil,
                                        userInfo: [AVAudioSessionInterruptionTypeKey: NSNumber(value: code)])
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
