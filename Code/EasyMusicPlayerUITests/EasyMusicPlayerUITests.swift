import XCTest
import AVFoundation

@MainActor
final class EasyMusicPlayerUITests: XCTestCase, Sendable {
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
        app.launch()
    }

    override func tearDown() async throws {
        app = nil

        try await super.tearDown()
    }

    func test_givenHappyPath_forMainFeatures_whenTapAllButtons_expectNoErrors() throws {
        // FIXME: Bitrise is failing when the play button is pressed, but it's not clear why
        //
        // this didn't help:
        // https://discuss.bitrise.io/t/how-to-create-a-virtual-audio-output-device-on-mac-os-stacks/1119/10
        //
        #if BITRISE_IO
        throw XCTSkip("Skipping UI tests in CI")
        return
        #endif

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

        waitSync(for: 1.0)

        let searchNavigationBar = app.navigationBars["Search"]
        let searchSearchField = searchNavigationBar.searchFields["Search"]

        searchSearchField.tap()
        searchSearchField.tap()

        // if these fail, make sure the keyboard is showing in the sim when
        // you select the field with: cmd+k
        app.keys["A"].tap()
        app.keys["r"].tap()

        searchSearchField.buttons["Clear text"].tap()
        searchNavigationBar.buttons["Cancel"].tap()

        waitSync(for: 1.0)

        let cell = app.collectionViews.children(matching: .cell).element(boundBy: 0)
        cell.children(matching: .other)
            .element(boundBy: 1)
            .children(matching: .other).element
            .children(matching: .other).element
            .tap()

        // stop
        stopButton.tap()
    }
}
