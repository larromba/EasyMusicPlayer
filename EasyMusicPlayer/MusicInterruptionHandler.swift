import AVFoundation
import Logging
import UIKit

protocol MusicInterruptionDelegate: AnyObject {
    func interruptionHandler(_ handler: MusicInterruptionHandler, handleAction action: InterruptionAction)
}

// sourcery: name = MusicInterruptionHandler
protocol MusicInterruptionHandling: Mockable {
    func setIsPlaying(_ isPlaying: Bool)
    func setDelegate(_ delegate: MusicInterruptionDelegate)
}

final class MusicInterruptionHandler: MusicInterruptionHandling {
    private weak var delegate: MusicInterruptionDelegate?
    private var state = MusicInterruptionState(
        disconnected: [],
        current: [],
        isPlaying: false,
        isPlayingInBackground: false,
        isExpectedToContinue: false,
        isAudioSessionInterrupted: false
    ) { didSet { log(state) } }
    private let session: AudioSession

    init(session: AudioSession) {
        self.session = session
        state.current = session.outputRoutes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive(_:)),
            name: UIApplication.willResignActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionRouteChange(_:)),
            name: AVAudioSession.routeChangeNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionInterruption(_:)),
            name: AVAudioSession.interruptionNotification,
            object: nil
        )
    }

    func setIsPlaying(_ isPlaying: Bool) {
        state.isPlaying = isPlaying
    }

    func setDelegate(_ delegate: MusicInterruptionDelegate) {
        self.delegate = delegate
    }

    // MARK: - private

    @objc
    private func applicationWillResignActive(_ notifcation: Notification) {
        if state.isPlaying {
            state.isPlayingInBackground = true
        }
    }

    @objc
    private func applicationDidBecomeActive(_ notifcation: Notification) {
        state.isPlayingInBackground = false
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
        switch reason {
        case .oldDeviceUnavailable:
            state.disconnected += previous.outputRoutes
            state.current = session.outputRoutes
            if state.isPlaying {
                state.isExpectedToContinue = true
                notify(.pause)
            }
        case .newDeviceAvailable:
            if !state.isPlaying && state.isExpectedToContinue && state.disconnected.intersects(session.outputRoutes)
            && !state.isAudioSessionInterrupted {
                notify(.play)
            }
            state.disconnected = []
            state.current = session.outputRoutes
        default:
            break
        }
    }

    // for the confusing nature of AVAudioSessionInterruptionWasSuspendedKey, see:
    // see https://developer.apple.com/documentation/avfoundation/avaudiosession/1616596-interruptionnotification
    @objc
    private func audioSessionInterruption(_ notification: Notification) {
        let userInfo = notification.userInfo
        logWarning("**** audioSessionInterruption ****", String(describing: userInfo))
        guard
            let key = (userInfo?[AVAudioSessionInterruptionWasSuspendedKey] as? Bool), !key,
            let rawValue = (userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSession.InterruptionType(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .began:
            state.isAudioSessionInterrupted = true
            if state.isPlaying {
                state.isExpectedToContinue = true
                notify(.pause)
            }
        case .ended:
            if !state.isPlaying && state.isExpectedToContinue && state.isAudioSessionInterrupted
            && !state.isDisconnected {
                notify(.play)
            }
            state.isAudioSessionInterrupted = false
        default:
            assertionFailure("unhandled AVAudioSession.InterruptionType")
        }
    }

    private func notify(_ action: InterruptionAction) {
        DispatchQueue.main.async {
            log("**** notifying interruption action: \(action) ****")
            self.delegate?.interruptionHandler(self, handleAction: action)
        }
    }
}

// MARK: - Array

private extension Array where Element == AVAudioSession.Port {
    func intersects(_ items: [AVAudioSession.Port]) -> Bool {
        guard !self.isEmpty && !items.isEmpty else { return false }
        return !Set(self).isDisjoint(with: Set(items))
    }
}
