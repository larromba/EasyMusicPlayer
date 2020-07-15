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
    private let session: AudioSession
    private var state = MusicInterruptionState(
        routeChangeInterruption: RouteChangeInterruption(),
        audioSessionInterruption: AudioSessionInterruption(),
        isPlaying: false,
        isPlayingInBackground: false
    ) { didSet { log(state) } }

    init(session: AudioSession) {
        self.session = session
        state.routeChangeInterruption.currentOutputRoutes = session.outputRoutes
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
            state.routeChangeInterruption.stage = .start
            state.routeChangeInterruption.disconnectedOutputRoutes += previous.outputRoutes
            state.routeChangeInterruption.currentOutputRoutes = session.outputRoutes
            if state.isPlaying {
                state.routeChangeInterruption.isAudioInterrupted = true
                notify(.pause)
            }
        case .newDeviceAvailable:
            state.routeChangeInterruption.stage = .end
            if state.isExpectedToContinue && state.routeChangeInterruption.didReattachDevice(session.outputRoutes) {
                state.finish()
                notify(.play)
            }
            state.routeChangeInterruption.disconnectedOutputRoutes = []
            state.routeChangeInterruption.currentOutputRoutes = session.outputRoutes
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
            state.audioSessionInterruption.stage = .start
            if state.isPlaying {
                state.audioSessionInterruption.isAudioInterrupted = true
                notify(.pause)
            }
        case .ended:
            state.audioSessionInterruption.stage = .end
            if state.isExpectedToContinue {
                state.finish()
                notify(.play)
            }
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
