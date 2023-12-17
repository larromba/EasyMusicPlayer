import Foundation

/// @mockable
protocol AudioClocking: AnyObject {
    var callback: (() -> Void)? { get set }

    func start()
    func stop()
}

// simple clock that ticks every second
final class AudioClock: AudioClocking {
    private var timer: Timer?
    private let tickInterval: TimeInterval
    var callback: (() -> Void)?

    init(tickInterval: TimeInterval = 1.0) {
        self.tickInterval = tickInterval
    }

    func start() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            withTimeInterval: 1.0,
            repeats: true,
            block: { [weak self] _ in
                self?.callback?()
            }
        )
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }
}
