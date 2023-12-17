import Foundation

/// @mockable
protocol Seekable: AnyObject {
    var seek: ((TimeInterval) -> Void)? { get set }

    func seek(_ action: SeekDirection)
    func stop()
}

enum SeekDirection {
    case forward
    case backward
}

final class Seeker: Seekable {
    private var seekTimer: Timer?
    private var seekStartDate: Date?
    private let seekInterval: TimeInterval
    private var time: TimeInterval {
        guard let seekStartDate else { return 1 }
        let timeElapsed = Date().timeIntervalSince(seekStartDate)
        if timeElapsed < 1 { return 1 }
        if timeElapsed < 2 { return 3 }
        if timeElapsed < 3 { return 5 }
        if timeElapsed < 4 { return 7 }
        if timeElapsed < 5 { return 9 }
        return 10
    }

    var seek: ((TimeInterval) -> Void)?

    init(seekInterval: TimeInterval = 0.2) {
        self.seekInterval = seekInterval
    }

    func seek(_ action: SeekDirection) {
        stop()

        seekStartDate = Date()
        seekTimer = Timer.scheduledTimer(withTimeInterval: seekInterval, repeats: true) { [weak self] _ in
            guard let self else { return }
            switch action {
            case .backward:
                self.seek?(time * -1)
            case .forward:
                self.seek?(time)
            }
        }
    }

    func stop() {
        seekTimer?.invalidate()
        seekTimer = nil
        seekStartDate = nil
    }
}
