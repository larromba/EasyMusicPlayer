import XCTest

@MainActor
final class EasyMusicPlayerUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        continueAfterFailure = false
        addUIInterruptionMonitor(withDescription: "permissions") { alert -> Bool in
            alert.buttons["Allow"].tap()
            return true
        }
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_whenTapAllButtons_expectFunctionsCorrectly() {
        let playButton = app.buttons["Play"]
        let scrubberElement = app.otherElements["Scrubber"]
        let nextButton = app.buttons["Next"]
        let previousButton = app.buttons["Previous"]
        let stopButton = app.buttons["Stop"]
        let shuffleButton = app.buttons["Shuffle"]
        let searchButton = app.buttons["Search"]
        let repeatButton = app.buttons["Repeat"]

        // play
        playButton.tap()

        // scrub
        scrubberElement.swipeRight()
        scrubberElement.swipeLeft()

        // pause
        playButton.tap()

        // next
        nextButton.tap()
        nextButton.tap()
        
        // previous
        previousButton.tap()
        previousButton.tap()
        
        // stop
        stopButton.tap()

        // repeat mode
        repeatButton.tap()
        repeatButton.tap()

        // shuffle
        shuffleButton.tap()

        // search
        searchButton.tap()

        let searchNavigationBar = app.navigationBars["Search"]
        let searchSearchField = searchNavigationBar.searchFields["Search"]
        searchSearchField.tap()
        searchSearchField.tap()

        app.keys["A"].tap()
        app.keys["r"].tap()

        searchSearchField.buttons["Clear text"].tap()
        searchNavigationBar.buttons["Cancel"].tap()
        
        let cell = app.collectionViews.children(matching: .cell).element(boundBy: 0)
        cell.children(matching: .other)
            .element(boundBy: 1)
            .children(matching: .other).element
            .children(matching: .other).element.tap()

        // stop
        stopButton.tap()
    }
}
