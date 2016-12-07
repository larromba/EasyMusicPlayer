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
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        XCUIApplication().terminate()
    }
    
    func testPlay() {
        XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0).tap()
    }
    
    func testPause() {
        let button = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0)
        button.tap()
        button.tap()
    }

    func testStop() {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0).tap()
        app.buttons["StopButton"].tap()
    }
    
    func testStopCantScrub() {
        XCUIApplication().staticTexts["00:00:00"].tap()
    }
    
    func testPrev() {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0).tap()
        app.buttons["NextButton"].tap()
        app.buttons["PreviousButton"].tap()
    }
    
    func testNext() {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0).tap()
        app.buttons["NextButton"].tap()
    }

    func testShuffle() {
        XCUIApplication().buttons["ShuffleButton"].tap()
    }
    
    func testScrubber() {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0).tap()
        app.staticTexts["00:00:00"].tap()
    }
    
    func testPlayInBg() {
        let app = XCUIApplication()
        app.children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element(boundBy: 1).children(matching: .button).element(boundBy: 0).tap()
        XCUIDevice.shared().press(XCUIDeviceButton.home)
    }
    
    func testRepeatMode() {
        let button = XCUIApplication().children(matching: .window).element(boundBy: 0).children(matching: .other).element.children(matching: .other).element(boundBy: 3).children(matching: .other).element.children(matching: .other).element(boundBy: 2).children(matching: .button).element(boundBy: 1)
        button.tap()
        button.tap()
        button.tap()
        button.tap()
    }
}
