import Foundation

protocol SeekerDelegate: AnyObject {
    func seeker(_ seeker: Seekable, updateDelta: TimeInterval)
}

protocol Seekable {
    func startSeekingWithAction(_ action: SeekAction)
    func stopSeeking()
    func setDelegate(_ delegate: SeekerDelegate)
}

enum SeekAction {
    case forward
    case backward
}

final class Seeker: Seekable {
    private var seekTimer: Timer?
    private var seekStartDate: Date?
    private let seekInterval: TimeInterval

    private weak var delegate: SeekerDelegate?

    init(seekInterval: TimeInterval) {
        self.seekInterval = seekInterval
    }

    func setDelegate(_ delegate: SeekerDelegate) {
        self.delegate = delegate
    }

    func startSeekingWithAction(_ action: SeekAction) {
        if seekTimer != nil {
            stopSeeking()
        }

        let selector: Selector
        switch action {
        case .forward:
            selector = #selector(seekForwardTimerCallback)
        case .backward:
            selector = #selector(seekBackwardTimerCallback)
        }

        seekStartDate = Date()
        seekTimer = Timer.scheduledTimer(
            timeInterval: seekInterval,
            target: self,
            selector: selector,
            userInfo: nil,
            repeats: true
        )
    }

    func stopSeeking() {
        seekTimer?.invalidate()
        seekTimer = nil
        seekStartDate = nil
    }

    // MARK: - private

    @objc
    private func seekForwardTimerCallback() {
        delegate?.seeker(self, updateDelta: 1.0)
    }

    @objc
    private func seekBackwardTimerCallback() {
        delegate?.seeker(self, updateDelta: -1.0)
    }
}
