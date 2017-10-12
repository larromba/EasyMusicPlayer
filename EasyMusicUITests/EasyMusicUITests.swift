//
//  EasyMusicUITests.swift
//  EasyMusicUITests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest

class EasyMusicUITests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        XCUIApplication().terminate()
        
        super.tearDown()
    }
    
    func testBasicUsage() {
        let app = XCUIApplication()
        app.buttons["PlayButton"].tap()
        app.staticTexts["00:00:00"].tap()
        
        let stopbuttonButton = app.buttons["StopButton"]
        stopbuttonButton.tap()
        app.buttons["ShuffleButton"].tap()
        app.buttons["PreviousButton"].tap()
        app.buttons["NextButton"].tap()
        app.buttons["RepeatAllButton"].tap()
        app.buttons["ShareButton"].tap()
        app.sheets["Share"].buttons["Cancel"].tap()
        stopbuttonButton.tap()
    }
}
