import XCTest

final class Snapshots: XCTestCase {
    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()

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
        app.otherElements
            .containing(.staticText, identifier:"v2.0.0")
            .children(matching: .other).element(boundBy: 1)
            .children(matching: .other).element
            .tap()
        snapshot("Main")
    }
}
