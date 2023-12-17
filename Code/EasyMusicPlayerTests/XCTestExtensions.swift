import Foundation
import XCTest

public extension XCTestCase {
    // see https://www.vadimbulavin.com/swift-asynchronous-unit-testing-with-busy-assertion-pattern/
    func waitSync(for duration: TimeInterval = 0.5) {
        RunLoop.current.run(until: Date(timeIntervalSinceNow: duration))
    }

    // see https://stackoverflow.com/questions/31182637/delay-wait-in-a-test-case-of-xcode-ui-testing
    func waitAsync(for duration: TimeInterval = 0.5, delay: TimeInterval = 0.0, queue: DispatchQueue = .main,
                   completion: @escaping (@escaping () -> Void) -> Void) {
        let expectation = self.expectation(description: "wait asynchronously for callback")
        queue.asyncAfter(deadline: .now() + delay) {
            completion {
                DispatchQueue.main.async { expectation.fulfill() }
            }
        }
        waitForExpectations(timeout: delay + duration)
    }
}
