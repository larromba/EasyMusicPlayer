import Foundation

typealias AudioClockCallback = (@Sendable () -> Void)?

/// @mockable
protocol AudioClocking: AnyObject, Sendable {
    func start()
    func stop()
    func setCallback(_ callback: AudioClockCallback)
}

// simple clock that ticks every second
final class AudioClock: AudioClocking {
    private let timer = LockIsolated<Timer?>(nil)
    private let tickInterval: TimeInterval
    private let callback = LockIsolated<AudioClockCallback>(nil)

    init(tickInterval: TimeInterval = 1.0) {
        self.tickInterval = tickInterval
    }

    func start() {
        timer.withValue { $0?.invalidate() }
        timer.setValue(
            Timer.scheduledTimer(
                withTimeInterval: 1.0,
                repeats: true,
                block: { [callback] _ in
                    callback.withValue { $0?() }
                }
            )
        )
    }

    func stop() {
        timer.withValue { $0?.invalidate() }
        timer.setValue(nil)
    }

    func setCallback(_ callback: AudioClockCallback) {
        self.callback.setValue(callback)
    }
}
