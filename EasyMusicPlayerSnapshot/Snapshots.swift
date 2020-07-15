import XCTest

final class Snapshots: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        addUIInterruptionMonitor(withDescription: "permissions") { alert -> Bool in
            alert.buttons["OK"].tap()
            return true
        }
        app = XCUIApplication()
        setupSnapshot(app)
        continueAfterFailure = false
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    func testMainSnapshot() {
        app.launch()
        app.buttons["PlayButton"].tap()
        if UIDevice.current.userInterfaceIdiom == .pad {
            app.children(matching: .window).element(boundBy: 0)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other)
            .element(boundBy: 1)
            .children(matching: .other).element.tap()
        } else {
            app.children(matching: .window)
            .element(boundBy: 0)
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other).element
            .children(matching: .other)
            .element(boundBy: 1)
            .children(matching: .other).element.tap()
        }
        snapshot("Main")
    }
}
