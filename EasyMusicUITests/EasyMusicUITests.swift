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
        XCUIDevice.sharedDevice().orientation = .Portrait
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
        XCUIApplication().terminate()
    }
    
    func testPlay() {
        XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button).elementBoundByIndex(0).tap()
    }
    
    func testPause() {
        let button = XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button).elementBoundByIndex(0)
        button.tap()
        button.tap()
    }

    func testStop() {
        let app = XCUIApplication()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        app.buttons["StopButton"].tap()
    }
    
    func testStopCantScrobble() {
        XCUIApplication().staticTexts["00:00:00"].tap()
    }
    
    func testPrev() {
        let app = XCUIApplication()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        app.buttons["NextButton"].tap()
        app.buttons["PreviousButton"].tap()
    }
    
    func testNext() {
        let app = XCUIApplication()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        app.buttons["NextButton"].tap()
    }

    func testShuffle() {
        XCUIApplication().buttons["ShuffleButton"].tap()
    }
    
    func testScrobble() {
        let app = XCUIApplication()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        app.staticTexts["00:00:00"].tap()
    }
    
    func testPlayInBg() {
        let app = XCUIApplication()
        app.childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(1).childrenMatchingType(.Button).elementBoundByIndex(0).tap()
        XCUIDevice.sharedDevice().pressButton(XCUIDeviceButton.Home)
    }
    
    func testRepeatMode() {
        let button = XCUIApplication().childrenMatchingType(.Window).elementBoundByIndex(0).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(3).childrenMatchingType(.Other).element.childrenMatchingType(.Other).elementBoundByIndex(2).childrenMatchingType(.Button).elementBoundByIndex(1)
        button.tap()
        button.tap()
        button.tap()
        button.tap()
    }
}
