import AVFoundation
import Foundation
import Logging

protocol MusicInterruptionDelegate: AnyObject {
    func interruptionHandler(_ handler: MusicInterruptionHandler, updtedState state: MusicInterruptionState)
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
        isHeadphonesRemovedByMistake: false,
        isPlayingInBackground: false,
        isAudioSessionInterrupted: false
    ) { didSet { log(state) } }

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillResignActive(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionRouteChange(_:)),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(audioSessionInterruption(_:)),
            name: NSNotification.Name.AVAudioSessionInterruption,
            object: nil
        )
    }

    func setIsPlaying(_ isPlaying: Bool) {
        self.isPlaying = isPlaying
        if isPlaying {
            state = state.copy(
                isHeadphonesRemovedByMistake: false,
                isAudioSessionInterrupted: false
            )
        }
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
            let reason = AVAudioSessionRouteChangeReason(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .oldDeviceUnavailable:
            if isPlaying {
                state = state.copy(isHeadphonesRemovedByMistake: true)
                notifyStateChange()
            }
        case .newDeviceAvailable:
            if !isPlaying && state.isHeadphonesRemovedByMistake {
                state = state.copy(isHeadphonesRemovedByMistake: false)
                notifyStateChange()
            }
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
            let reason = AVAudioSessionInterruptionType(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .began:
            if isPlaying {
                state = state.copy(isAudioSessionInterrupted: true)
                notifyStateChange()
            }
        case .ended:
            if !isPlaying && state.isAudioSessionInterrupted {
                state = state.copy(isAudioSessionInterrupted: false)
                notifyStateChange()
            }
        }
    }

    private func notifyStateChange() {
        DispatchQueue.main.async {
            log("**** notifyStateChange ****")
            self.delegate?.interruptionHandler(self, updtedState: self.state)
        }
    }
}
