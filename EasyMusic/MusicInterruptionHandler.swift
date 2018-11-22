import AVFoundation
import Foundation

protocol MusicInterupptionDelegate: AnyObject {
    func interupptionHandler(_ handler: MusicInterupptionHandler, updtedState state: MusicInterupptionState)
}

protocol MusicInterupptionHandling {
    func setIsPlaying(_ isPlaying: Bool)
    func setDelegate(_ delegate: MusicInterupptionDelegate)
}

final class MusicInterupptionHandler: MusicInterupptionHandling {
    private var isPlaying: Bool = false
    private weak var delegate: MusicInterupptionDelegate?
    private var state = MusicInterupptionState(
        isHeadphonesRemovedByMistake: false,
        isPlayingInBackground: false,
        isAudioSessionInterrupted: false
    )

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
            reset()
        }
    }

    func setDelegate(_ delegate: MusicInterupptionDelegate) {
        self.delegate = delegate
    }

    // MARK: - private

    private func reset() {
        state = MusicInterupptionState(
            isHeadphonesRemovedByMistake: false,
            isPlayingInBackground: false,
            isAudioSessionInterrupted: false
        )
    }

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
    private func audioSessionRouteChange(_ notifcation: Notification) {
        guard
            let rawValue = (notifcation.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSessionRouteChangeReason(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .oldDeviceUnavailable:
            if isPlaying {
                state = state.copy(isHeadphonesRemovedByMistake: true)
                delegate?.interupptionHandler(self, updtedState: state)
            }
        case .newDeviceAvailable:
            if !isPlaying && state.isHeadphonesRemovedByMistake {
                state = state.copy(isHeadphonesRemovedByMistake: false)
                delegate?.interupptionHandler(self, updtedState: state)
            }
        default:
            break
        }
    }

    @objc
    private func audioSessionInterruption(_ notification: Notification) {
        guard
            let rawValue = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSessionInterruptionType(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .began:
            if state.isPlayingInBackground || isPlaying {
                state = state.copy(isAudioSessionInterrupted: true)
                delegate?.interupptionHandler(self, updtedState: state)
            }
        case .ended:
            if !isPlaying && state.isAudioSessionInterrupted {
                state = state.copy(isAudioSessionInterrupted: false)
                delegate?.interupptionHandler(self, updtedState: state)
            }
        }
    }
}
