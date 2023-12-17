import AVFoundation
import UIKit

/// @mockable
protocol MusicInterruptionHandling: AnyObject {
    var callback: ((MusicInterruptionAction) -> Void)? { get set }
    var isPlaying: Bool { get set }
}

// stops the music when something got disconnected
// starts the music when it's reconnected
// it's suprisingly complicated
final class MusicInterruptionHandler: MusicInterruptionHandling {
    var callback: ((MusicInterruptionAction) -> Void)?
    var isPlaying: Bool {
        get { state.isPlaying }
        set { state.isPlaying = newValue }
    }

    private let session: AudioSession
    private let notificationCenter: NotificationCenter
    private var state = MusicInterruptionState(
        routeChangeInterruption: RouteChangeInterruption(),
        audioSessionInterruption: AudioSessionInterruption(),
        isPlaying: false,
        isPlayingInBackground: false
    ) // { didSet { log(state) } }

    init(
        session: AudioSession = AVAudioSession.sharedInstance(),
        notificationCenter: NotificationCenter = .default
    ) {
        self.session = session
        self.notificationCenter = notificationCenter
        setup()
    }

    private func setup() {
        state.routeChangeInterruption.currentOutputRoutes = session.outputRoutes

        notificationCenter.addObserver(
            forName: UIApplication.willResignActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            guard state.isPlaying else { return }
            state.isPlayingInBackground = true
        }
        notificationCenter.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.state.isPlayingInBackground = false
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
            let outputRoutes = session.outputRoutes
            if state.isExpectedToContinue && state.routeChangeInterruption.didReattachDevice(outputRoutes) {
                state.finish()
                notify(.play)
            }
            state.routeChangeInterruption.disconnectedOutputRoutes = []
            state.routeChangeInterruption.currentOutputRoutes = outputRoutes
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
            let interruptionReasonRawValue = (userInfo?[AVAudioSessionInterruptionReasonKey] as? NSNumber)?.uintValue,
            let interruptionReason = AVAudioSession.InterruptionReason(rawValue: interruptionReasonRawValue),
            let interruptionTypeRawValue = (userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let interruptionType = AVAudioSession.InterruptionType(rawValue: interruptionTypeRawValue) else {
                return
        }

        logWarning("found reason: \(interruptionReason)")

        switch interruptionType {
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
            assertionFailure("unhandled: \(AVAudioSession.InterruptionType.self)")
        }
    }

    private func notify(_ action: MusicInterruptionAction) {
        DispatchQueue.main.async {
            log("**** notifying interruption action: \(action) ****")
            self.callback?(action)
        }
    }
}
