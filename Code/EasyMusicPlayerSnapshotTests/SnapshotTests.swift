import XCTest

@MainActor
final class SnapshotTests: XCTestCase, Sendable {
    private var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        continueAfterFailure = false
        app = XCUIApplication()
        // music library permissions
        addUIInterruptionMonitor(withDescription: "permissions") { alert -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        setupSnapshot(app)
        app.launch()
    }

    override func tearDown() async throws {
        app = nil

        try await super.tearDown()
    }

    func test_whenLaunchApp_expectGenerateSnapshots() throws {
        app.tap()

        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowButton = springboard.buttons["Allow"]
        if allowButton.waitForExistence(timeout: 2) {
            allowButton.tap()
        }

        let playButton = app.buttons["Play"]
        playButton.tap()

        let scrubberElement = app.otherElements["Scrubber"]
        scrubberElement.swipeRight()

        snapshot("Main")
    }
}
