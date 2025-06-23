import AVFoundation
import UIKit

typealias MusicInterruptionHandlerCallback = (@Sendable (MusicInterruptionAction) -> Void)?

/// @mockable
protocol MusicInterruptionHandling: AnyObject, Sendable {
    var isPlaying: Bool { get set }

    func setCallback(_ callback: MusicInterruptionHandlerCallback)
}

/// stops the music when something got disconnected
/// starts the music when it's reconnected
/// ...it's suprisingly complicated
final class MusicInterruptionHandler: MusicInterruptionHandling {
    var isPlaying: Bool {
        get { state.withValue { $0.isPlaying } }
        set { state.withValue { $0.isPlaying = newValue } }
    }

    private let session: AudioSession
    private let notificationCenter: NotificationCenter
    private let callback = LockIsolated<MusicInterruptionHandlerCallback>(nil)
    private let state = LockIsolated<MusicInterruptionState>(
        MusicInterruptionState(
            routeChangeInterruption: RouteChangeInterruption(),
            audioSessionInterruption: AudioSessionInterruption(),
            isPlaying: false,
            isPlayingInBackground: false
        )
    ) // { didSet { log(state) } }

    init(
        session: AudioSession = AVAudioSession.sharedInstance(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.session = session
        self.notificationCenter = notificationCenter
        setup()
    }

    func setCallback(_ callback: MusicInterruptionHandlerCallback) {
        self.callback.setValue(callback)
    }

    private func setup() {
        state.withValue {
            $0.routeChangeInterruption.currentOutputRoutes = session.outputRoutes
        }

        notificationCenter.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.state.withValue {
                guard $0.isPlaying else { return }
                $0.isPlayingInBackground = true
            }
        }
        notificationCenter.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.state.withValue {
                $0.isPlayingInBackground = false
            }
        }
        notificationCenter.addObserver(
            forName: AVAudioSession.routeChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.audioSessionRouteChange(notification)
        }
        notificationCenter.addObserver(
            forName: AVAudioSession.interruptionNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.audioSessionInterruption(notification)
        }
    }

    @objc
    private func audioSessionRouteChange(_ notification: Notification) {
        let userInfo = notification.userInfo
        logWarning("**** audioSessionRouteChange ****", String(describing: userInfo))
        guard
            let previous = userInfo?[AVAudioSessionRouteChangePreviousRouteKey] as? AudioSessionRouteDescription,
            let rawValue = (userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue) else {
                return
        }
        state.withValue {
            switch reason {
            case .oldDeviceUnavailable:
                $0.routeChangeInterruption.stage = .start
                $0.routeChangeInterruption.disconnectedOutputRoutes += previous.outputRoutes
                $0.routeChangeInterruption.currentOutputRoutes = session.outputRoutes
                if $0.isPlaying {
                    $0.routeChangeInterruption.isAudioInterrupted = true
                    notify(.pause)
                }
            case .newDeviceAvailable:
                $0.routeChangeInterruption.stage = .end
                let outputRoutes = session.outputRoutes
                if $0.isExpectedToContinue && $0.routeChangeInterruption.didReattachDevice(outputRoutes) {
                    $0.finish()
                    notify(.play)
                }
                $0.routeChangeInterruption.disconnectedOutputRoutes = []
                $0.routeChangeInterruption.currentOutputRoutes = outputRoutes
            default:
                break
            }
        }
    }

    // for the confusing nature of AVAudioSessionInterruptionWasSuspendedKey, see:
    // see https://developer.apple.com/documentation/avfoundation/avaudiosession/1616596-interruptionnotification
    @objc
    private func audioSessionInterruption(_ notification: Notification) {
        let userInfo = notification.userInfo
        logWarning("**** audioSessionInterruption ****", String(describing: userInfo))
        guard
            let interruptionReasonRawValue = (userInfo?[AVAudioSessionInterruptionReasonKey] as? NSNumber)?.uintValue,
            let interruptionReason = AVAudioSession.InterruptionReason(rawValue: interruptionReasonRawValue),
            let interruptionTypeRawValue = (userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRawValue) else {
                return
        }

        logWarning("found reason: \(interruptionReason)")

        state.withValue {
            switch interruptionType {
            case .began:
                $0.audioSessionInterruption.stage = .start
                if $0.isPlaying {
                    $0.audioSessionInterruption.isAudioInterrupted = true
                    notify(.pause)
                }
            case .ended:
                $0.audioSessionInterruption.stage = .end
                if $0.isExpectedToContinue {
                    $0.finish()
                    notify(.play)
                }
            default:
                assertionFailure("unhandled: \(AVAudioSession.InterruptionType.self)")
            }
        }
    }

    private func notify(_ action: MusicInterruptionAction) {
        Task { @MainActor in
            log("**** notifying interruption action: \(action) ****")
            self.callback.withValue { $0?(action) }
        }
    }
}
