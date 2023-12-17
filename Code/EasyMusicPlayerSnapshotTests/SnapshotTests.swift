import XCTest

@MainActor
final class SnapshotTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        app = XCUIApplication()
        addUIInterruptionMonitor(withDescription: "permissions") { alert -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        setupSnapshot(app)
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app = nil
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
