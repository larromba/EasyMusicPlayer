@testable import Logging
import XCTest

final class GlobalLogTests: XCTestCase {
    override func setUp() {
        super.setUp()
        _playgroundPrintHook = nil
    }

    override func tearDown() {
        _playgroundPrintHook = nil
        super.tearDown()
    }

    func testGlobalLogOutput() {
        // mocks
        var output = [String]()
        _playgroundPrintHook = { message in
            output += [message]
        }

        // sut
        log("a message", 2)
        logWarning("a message", [2])
        logError("a message", 2, separator: "<")
        logMagic("a message", 2, terminator: "|")
        logHack("a message", 2)

        // test
        XCTAssertEqual(output, ["ℹ️ a message 2\n",
                                "⚠️ a message [2]\n",
                                "❌<a message<2\n",
                                "🦄 a message 2|",
                                "💩 a message 2\n"])
    }
}
