import Foundation

typealias SeekCallback = (@Sendable (TimeInterval) -> Void)?

/// @mockable
protocol Seekable: AnyObject, Sendable {
    func setSeekCallback(_ seekCallback: SeekCallback)
    func seek(_ action: SeekDirection)
    func stop()
}

enum SeekDirection {
    case forward
    case backward
}

final class Seeker: Seekable {
    private let seekTimer = LockIsolated<Timer?>(nil)
    private let seekStartDate = LockIsolated<Date?>(nil)
    private let seekCallback = LockIsolated<SeekCallback>(nil)
    private let seekInterval: TimeInterval
    private var time: TimeInterval {
        seekStartDate.withValue {
            guard let seekStartDate = $0 else { return 1 }
            let timeElapsed = Date().timeIntervalSince(seekStartDate)
            if timeElapsed < 1 { return 1 }
            if timeElapsed < 2 { return 3 }
            if timeElapsed < 3 { return 5 }
            if timeElapsed < 4 { return 7 }
            if timeElapsed < 5 { return 9 }
            return 10
        }
    }

    init(seekInterval: TimeInterval = 0.2) {
        self.seekInterval = seekInterval
    }

    func setSeekCallback(_ seekCallback: SeekCallback) {
        self.seekCallback.setValue(seekCallback)
    }

    func seek(_ action: SeekDirection) {
        stop()

        seekStartDate.setValue(Date())
        seekTimer.setValue(
            Timer.scheduledTimer(withTimeInterval: seekInterval, repeats: true) { [weak self] _ in
                guard let self else { return }
                switch action {
                case .backward:
                    seekCallback.withValue { $0?(time * -1) }
                case .forward:
                    seekCallback.withValue { $0?(time) }
                }
            }
        )
    }

    func stop() {
        seekTimer.withValue { $0?.invalidate() }
        seekTimer.setValue(nil)
        seekStartDate.setValue(nil)
    }
}
