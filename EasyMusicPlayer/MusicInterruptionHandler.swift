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
    private var isPlaying: Bool = false
    private weak var delegate: MusicInterruptionDelegate?
    private var state = MusicInterruptionState(
        isHeadphonesAttached: false,
        isPlayingInBackground: false,
        isAudioSessionInterrupted: false
    ) { didSet { log(state) } }

    init(session: AudioSessioning) {
        let isHeadphonesAttached = !session.currentRoute.outputs.filter {
            $0.portName == AVAudioSession.Port.headphones.rawValue
        }.isEmpty
        state = state.copy(isHeadphonesAttached: isHeadphonesAttached)

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
        self.isPlaying = isPlaying
    }

    func setDelegate(_ delegate: MusicInterruptionDelegate) {
        self.delegate = delegate
    }

    // MARK: - private

    @objc
    private func applicationWillResignActive(_ notifcation: Notification) {
        if isPlaying {
            state = state.copy(isPlayingInBackground: true)
        }
    }

    @objc
    private func applicationDidBecomeActive(_ notifcation: Notification) {
        state = state.copy(isPlayingInBackground: false)
    }

    @objc
    private func audioSessionRouteChange(_ notification: Notification) {
        logWarning("**** audioSessionRouteChange ****", String(describing: notification.userInfo))
        guard
            let rawValue = (notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSession.RouteChangeReason(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .oldDeviceUnavailable:
            state = state.copy(isHeadphonesAttached: false)
            if isPlaying {
                notify(.pause)
            }
        case .newDeviceAvailable:
            if !isPlaying && !state.isHeadphonesAttached && !state.isAudioSessionInterrupted {
                notify(.play)
            }
            state = state.copy(isHeadphonesAttached: true)
        default:
            break
        }
    }

    // for the confusing nature of AVAudioSessionInterruptionWasSuspendedKey, see:
    // see https://developer.apple.com/documentation/avfoundation/avaudiosession/1616596-interruptionnotification
    @objc
    private func audioSessionInterruption(_ notification: Notification) {
        logWarning("**** audioSessionInterruption ****", String(describing: notification.userInfo))
        guard
            let rawValue = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let key = (notification.userInfo?[AVAudioSessionInterruptionWasSuspendedKey] as? Bool), !key,
            let reason = AVAudioSession.InterruptionType(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .began:
            state = state.copy(isAudioSessionInterrupted: true)
            if isPlaying {
                notify(.pause)
            }
        case .ended:
            if !isPlaying && state.isAudioSessionInterrupted && state.isHeadphonesAttached {
                notify(.play)
            }
            state = state.copy(isAudioSessionInterrupted: false)
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
