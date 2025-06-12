import XCTest

@MainActor
final class SnapshotTests: XCTestCase, Sendable {
    private var app: XCUIApplication!

    override func setUp() async throws {
        try await super.setUp()

        app = XCUIApplication()
        addUIInterruptionMonitor(withDescription: "permissions") { alert -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        setupSnapshot(app)
        continueAfterFailure = false
    }

    override func tearDown() async throws {
        app = nil

        try await super.tearDown()
    }

    func test_whenLaunchApp_expectGenerateSnapshots() throws {
        app.launch()

        app.tap()
        let springboard = XCUIApplication(bundleIdentifier: "com.apple.springboard")
        let allowButton = springboard.buttons["Allow"]
        if allowButton.waitForExistence(timeout: 2) {
            allowButton.tap()
        }

        let playButton = app.buttons["Play"]
        let scrubberElement = app.otherElements["Scrubber"]
        let repeatButton = app.buttons["Repeat"]

        repeatButton.tap()
        repeatButton.tap()

        playButton.tap()

        scrubberElement.swipeRight()

        snapshot("Main")
    }
}
