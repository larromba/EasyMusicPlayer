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

class ScrobbleViewTests: XCTestCase {
    var scrobbleView: ScrobbleView!
    var scrobbleViewExpectation: XCTestExpectation!

    class MockTouch : UITouch {
        override func locationInView(view: UIView?) -> CGPoint {
            return mockPoint
        }
    }
    
    override func setUp() {
        super.setUp()        
        scrobbleView = ScrobbleView(frame: CGRectMake(0, 0, 100, 0))
        scrobbleView.delegate = self
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
    
    func testTouchesEnded() {
        /**
        expectations
        - delegate method is called
        */
        scrobbleViewExpectation = expectationWithDescription("ScrobbleViewDelegate.touchEndedAtPercentage(_, _)")
        
        let mockTouch = UITouch()
        let mockEvent = UIEvent()
        
        scrobbleView.enabled = true
        scrobbleView.touchesEnded(Set(arrayLiteral: mockTouch), withEvent: mockEvent)
        
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ScrobbleViewDelegate
extension ScrobbleViewTests: ScrobbleViewDelegate {
    func touchMovedToPercentage(sender: ScrobbleView, percentage: Float) { }
    func touchEndedAtPercentage(sender: ScrobbleView, percentage: Float) {
        scrobbleViewExpectation.fulfill()
    }
}