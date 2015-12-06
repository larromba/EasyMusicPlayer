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
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        XCUIDevice.sharedDevice().orientation = .Portrait
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
}
