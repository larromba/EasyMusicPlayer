import Foundation

protocol Clocking {
    func start()
    func stop()
    func setDelegate(_ delegate: ClockDelegate)
}

protocol ClockDelegate: AnyObject {
    func clockTicked(_ clock: Clock)
}

final class Clock: Clocking {
    private var timer: Timer?
    private weak var delegate: ClockDelegate?
    private let timeInterval: TimeInterval

    init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }

    func start() {
        if timer != nil {
            stop()
        }
        timer = Timer.scheduledTimer(
            timeInterval: timeInterval,
            target: self,
            selector: #selector(playbackCheckTimerCallback),
            userInfo: nil,
            repeats: true
        )
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    func setDelegate(_ delegate: ClockDelegate) {
        self.delegate = delegate
    }

    // MARK: - private

    @objc
    private func playbackCheckTimerCallback() {
        delegate?.clockTicked(self)
    }
}
