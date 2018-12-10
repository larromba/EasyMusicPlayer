import AVFoundation
@testable import EasyMusic
import TestExtensions
import XCTest

final class MusicInterruptionTests: XCTestCase {
    func testInterruptionStartedPausesMusic() {
        // mocks
        let env = PlayerEnvironment()
        env.inject()

        // sut
        env.musicService.play()
        interrupt()

        // test
        wait(for: 0.5) {
            XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
        }
    }

    func testInterruptionEndedPlaysMusic() {
        // mocks
        let env = PlayerEnvironment()
        env.inject()

        // sut
        env.musicService.play()
        interrupt()
        uninterrupt()

        // test
        wait(for: 0.5) {
            XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
        }
    }

    func testHeadphonesRemovedPausesMusic() {
        // mocks
        let env = PlayerEnvironment()
        env.inject()

        // sut
        env.musicService.play()
        removeHeadphones()

        // test
        wait(for: 0.5) {
            XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.pause3.name) ?? false)
        }
    }

    func testHeadphonesReattachedPlaysMusic() {
        // mocks
        let env = PlayerEnvironment()
        env.inject()

        // sut
        env.musicService.play()
        removeHeadphones()
        attachHeadphones()

        // test
        wait(for: 0.5) {
            XCTAssertTrue(env.playerFactory.audioPlayer?.invocations.isInvoked(MockAudioPlayer.play2.name) ?? false)
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
