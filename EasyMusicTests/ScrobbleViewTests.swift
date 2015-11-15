//
//  ScrobbleViewTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
@testable import EasyMusic

private var mockPoint: CGPoint!

class MockTouch : UITouch {
    override func locationInView(view: UIView?) -> CGPoint {
        return mockPoint
    }
}

class ScrobbleViewTests: XCTestCase {
    var scrobbleView: ScrobbleView!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        scrobbleView = ScrobbleView(frame: CGRectMake(0, 0, 100, 0))
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testScrobble50() {
        scrobbleView.scrobbleToPercentage(0.5)
        XCTAssert(CGRectGetWidth(scrobbleView.barView.bounds) == 50.0)
    }
    
    func testScrobble30() {
        scrobbleView.scrobbleToPercentage(0.3)
        XCTAssert(CGRectGetWidth(scrobbleView.barView.bounds) == 30.0)
    }
    
    func testScrobble90() {
        scrobbleView.scrobbleToPercentage(0.9)
        XCTAssert(CGRectGetWidth(scrobbleView.barView.bounds) == 90.0)
    }
    
    func testTouchesMoved50() {
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(50, 0)

        scrobbleView.enabled = true
        scrobbleView.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        XCTAssert(CGRectGetWidth(scrobbleView.barView.bounds) == 50.0)
    }
    
    func testTouchesMoved30() {
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(30, 0)
        
        scrobbleView.enabled = true
        scrobbleView.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        XCTAssert(CGRectGetWidth(scrobbleView.barView.bounds) == 30.0)
    }
    
    func testTouchesMoved90() {
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(90, 0)
        
        scrobbleView.enabled = true
        scrobbleView.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        XCTAssert(CGRectGetWidth(scrobbleView.barView.bounds) == 90.0)
    }
    
    func testTouchesMovedDisabled() {
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(90, 0)
        
        scrobbleView.enabled = false
        scrobbleView.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        XCTAssert(CGRectGetWidth(scrobbleView.barView.bounds) != 90.0)
    }
}