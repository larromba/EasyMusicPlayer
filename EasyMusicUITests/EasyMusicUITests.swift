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
        XCUIDevice.shared().orientation = .portrait
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        XCUIApplication().terminate()
        
        super.tearDown()
    }
    
    func testBasicUsage() {
        let app = XCUIApplication()
        let element = app.otherElements.containing(.staticText, identifier:"v1.1.4").children(matching: .other).element(boundBy: 3).children(matching: .other).element
        let button = element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0)
        button.tap()
        app.staticTexts["00:00:01"].tap()
        button.tap()
        button.tap()
        
        let nextbuttonButton = app.buttons["NextButton"]
        let previousbuttonButton = app.buttons["PreviousButton"]
        nextbuttonButton.tap()
        nextbuttonButton.tap()
        previousbuttonButton.tap()
        previousbuttonButton.tap()
        
        let stopbuttonButton = app.buttons["StopButton"]
        stopbuttonButton.tap()
        button.tap()
        
        let button2 = element.children(matching: .other).element(boundBy: 2).children(matching: .button).element(boundBy: 1)
        button2.tap()
        button2.tap()
        button2.tap()
        
        app.buttons["ShuffleButton"].tap()
        
        app.buttons["ShareButton"].tap()
        app.sheets["Share"].buttons["Cancel"].tap()
    }
}
