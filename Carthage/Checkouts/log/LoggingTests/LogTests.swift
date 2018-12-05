@testable import Logging
import XCTest

final class LogTests: XCTestCase {
    override func setUp() {
         super.setUp()
        _playgroundPrintHook = nil
    }

    override func tearDown() {
        _playgroundPrintHook = nil
        super.tearDown()
    }

    func testCustomLogDisabled() {
        // mocks
        var output = [String]()
        _playgroundPrintHook = { message in
            output += [message]
        }
        enum CustomLog: Log {
            static var isEnabled: Bool = false
        }

        // sut
        CustomLog.info("")
        CustomLog.warning("")
        CustomLog.error("")
        CustomLog.magic("")
        CustomLog.hack("")

        // test
        XCTAssertTrue(output.isEmpty)
    }

    func testCustomLogEnabled() {
        // mocks
        var output = [String]()
        _playgroundPrintHook = { message in
            output += [message]
        }
        enum CustomLog: Log {
            static var isEnabled: Bool = true
        }

        // sut
        CustomLog.info("a message", 2)
        CustomLog.warning("a message", [2])
        CustomLog.error("a message", 2, separator: "<")
        CustomLog.magic("a message", 2, terminator: "|")
        CustomLog.hack("a message", 2)

        // test
        XCTAssertEqual(output, ["ℹ️ CustomLog: a message 2\n",
                                "⚠️ CustomLog: a message [2]\n",
                                "❌<CustomLog:<a message<2\n",
                                "🦄 CustomLog: a message 2|",
                                "💩 CustomLog: a message 2\n"])
    }
}
