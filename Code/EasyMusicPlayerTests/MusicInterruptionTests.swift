import AVFoundation
@testable import EasyMusicPlayer
import Testing
import XCTest

@Suite(.serialized)
struct MusicInterruptionTests: Waitable {
    private let session: AudioSessionMock
    private let previous = AudioSessionRouteDescriptionMock()
    private let interruptionHandler: MusicInterruptionHandler
    private let notificationCenter = NotificationCenter.default

    init() {
        let session = AudioSessionMock()
        self.session = session
        interruptionHandler = MusicInterruptionHandler(session: session)
    }

    @Test
    func interruption_whenStarted_expectMusicPaused() async throws {
        let action = LockIsolated<MusicInterruptionAction?>(nil)

        // interrupt
        interruptionHandler.isPlaying = true
        interruptionHandler.setCallback {
            action.setValue($0)
        }
        try await interrupt()

        #expect(action.value == .pause)
    }

    @Test
    func interruption_whenEnded_expectMusicPlayed() async throws {
        let action = LockIsolated<MusicInterruptionAction?>(nil)

        // interrupt
        interruptionHandler.isPlaying = true
        try await interrupt()

        // uninterrupt
        interruptionHandler.isPlaying = false
        interruptionHandler.setCallback {
            action.setValue($0)
        }
        try await uninterrupt()

        #expect(action.value == .play)
    }

    @Test
    func interruption_whenHeadphonesRemoved_expectMusicPaused() async throws {
        let action = LockIsolated<MusicInterruptionAction?>(nil)

        // remove headphones
        interruptionHandler.isPlaying = true
        interruptionHandler.setCallback {
            action.setValue($0)
        }
        try await removeHeadphones()

        #expect(action.value == .pause)
    }

    @Test
    func interruption_whenHeadphonesReattached_expectMusicPlayed() async throws {
        let action = LockIsolated<MusicInterruptionAction?>(nil)

        // remove headphones
        interruptionHandler.isPlaying = true
        try await removeHeadphones()

        // attach headphones
        interruptionHandler.isPlaying = false
        interruptionHandler.setCallback {
            action.setValue($0)
        }
        try await attachHeadphones()

        #expect(action.value == .play)
    }

    @Test
    func interruption_whenStoppedAndHeadphonesReattached_expectDoesNotPlayMusic() async throws {
        let action = LockIsolated<MusicInterruptionAction?>(nil)

        // remove headphones
        interruptionHandler.isPlaying = false
        try await removeHeadphones()

        // attach headphones
        interruptionHandler.setCallback {
            action.setValue($0)
        }
        try await attachHeadphones()

        #expect(action.value == nil)
    }

    @Test
    func interruption_whenDifferentOutputReattached_expectDoesNotPlayMusic() async throws {
        let action = LockIsolated<MusicInterruptionAction?>(nil)

        // remove headphones
        interruptionHandler.isPlaying = true
        try await removeHeadphones()

        // attach different headphones
        interruptionHandler.isPlaying = false
        interruptionHandler.setCallback {
            action.setValue($0)
        }
        try await attachBluetoothHeadphones()

        #expect(action.value == nil)
    }

    @Test
    func interruption_whenHeadphonesRemovedAndReattachedBeforeInterruptionFinishes_expectDoesNotTakePriority() async throws {
        let actionBeforeInterruptionFinishes = LockIsolated<MusicInterruptionAction?>(nil)
        let actionAfterInterruptionFinishes = LockIsolated<MusicInterruptionAction?>(nil)

        // remove headphones
        interruptionHandler.isPlaying = true
        try await removeHeadphones()

        // interrupt
        interruptionHandler.isPlaying = false
        interruptionHandler.setCallback {
            actionBeforeInterruptionFinishes.setValue($0)
        }
        try await interrupt()

        // attach headphones
        try await attachHeadphones()

        // interrupt
        interruptionHandler.setCallback {
            actionAfterInterruptionFinishes.setValue($0)
        }
        try await uninterrupt()

        #expect(actionBeforeInterruptionFinishes.value == nil)
        #expect(actionAfterInterruptionFinishes.value == .play)
    }

    @Test
    func test_interruption_whenHeadphonesRemovedAndReattachedAfterInterruptionFinishes_expectDoesNotTakePriority() async throws {
        let actionBeforeInterruptionFinishes = LockIsolated<MusicInterruptionAction?>(nil)
        let actionAfterInterruptionFinishes = LockIsolated<MusicInterruptionAction?>(nil)

        // interrupt
        interruptionHandler.isPlaying = true
        try await interrupt()

        // remove headphones
        interruptionHandler.isPlaying = false
        interruptionHandler.setCallback {
            actionBeforeInterruptionFinishes.setValue($0)
        }
        try await  removeHeadphones()

        // uninterrupt
        try await uninterrupt()

        // attach headphones
        interruptionHandler.setCallback {
            actionAfterInterruptionFinishes.setValue($0)
        }
        try await attachHeadphones()

        #expect(actionBeforeInterruptionFinishes.value == nil)
        #expect(actionAfterInterruptionFinishes.value == .play)
    }

    private func interrupt() async throws {
        let code = AVAudioSession.InterruptionType.began.rawValue
        let notification = Notification(
            name: AVAudioSession.interruptionNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                AVAudioSessionInterruptionReasonKey: NSNumber(value: 0)
            ]
        )
        notificationCenter.post(notification)
        try await waitSync()
    }

    private func uninterrupt() async throws {
        let code = AVAudioSession.InterruptionType.ended.rawValue
        let notification = Notification(
            name: AVAudioSession.interruptionNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionInterruptionTypeKey: NSNumber(value: code),
                AVAudioSessionInterruptionReasonKey: NSNumber(value: 0)
            ]
        )
        notificationCenter.post(notification)
        try await waitSync()
    }

    private func removeHeadphones() async throws {
        previous.outputRoutes = [AVAudioSession.Port.headphones]
        session.outputRoutes = [AVAudioSession.Port.builtInSpeaker]
        let code = AVAudioSession.RouteChangeReason.oldDeviceUnavailable.rawValue
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionRouteChangeReasonKey: NSNumber(value: code),
                AVAudioSessionRouteChangePreviousRouteKey: previous
            ]
        )
        NotificationCenter.default.post(notification)
        try await waitSync()
    }

    private func attachHeadphones() async throws {
        session.outputRoutes = [AVAudioSession.Port.headphones]
        let code = AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionRouteChangeReasonKey: NSNumber(value: code),
                AVAudioSessionRouteChangePreviousRouteKey: previous
            ]
        )
        notificationCenter.post(notification)
        previous.outputRoutes = [AVAudioSession.Port.headphones]
        try await waitSync()
    }

    private func attachBluetoothHeadphones() async throws {
        session.outputRoutes = [AVAudioSession.Port.bluetoothA2DP]
        let code = AVAudioSession.RouteChangeReason.newDeviceAvailable.rawValue
        let notification = Notification(
            name: AVAudioSession.routeChangeNotification, 
            object: nil,
            userInfo: [
                AVAudioSessionRouteChangeReasonKey: NSNumber(value: code),
                AVAudioSessionRouteChangePreviousRouteKey: previous
            ]
        )
        notificationCenter.post(notification)
        try await waitSync()
    }
}
