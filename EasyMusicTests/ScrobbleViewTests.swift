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
    private var scrobbleView: ScrobbleView?
    private var scrobbleViewExpectation: XCTestExpectation?

    private class MockTouch : UITouch {
        override func locationInView(view: UIView?) -> CGPoint {
            return mockPoint
        }
    }
    
    override func setUp() {
        super.setUp()
        
        scrobbleView = ScrobbleView(frame: CGRectMake(0, 0, 100, 0))
        scrobbleView!.delegate = self
    }
    
    override func tearDown() {
        super.tearDown()
        
        scrobbleView = nil
        scrobbleViewExpectation = nil
    }
    
    func testScrobble50() {
        /**
        expectations:
        - moves to 50% of the screen
        */
        
        // runnable
        scrobbleView!.scrobbleToPercentage(0.5)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrobbleView!.barView.bounds), 50.0)
    }
    
    func testScrobble30() {
        /**
        expectations:
        - moves to 30% of the screen
        */
        
        // runnable
        scrobbleView!.scrobbleToPercentage(0.3)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrobbleView!.barView.bounds), 30.0)
    }
    
    func testScrobble90() {
        /**
        expectations:
        - moves to 90% of the screen
        */
        
        // runnable
        scrobbleView!.scrobbleToPercentage(0.9)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrobbleView!.barView.bounds), 90.0)
    }
    
    func testTouchesMoved50() {
        /**
         expectations:
         - moves to 50% of the screen
         - delegate called
         */
        scrobbleViewExpectation = expectationWithDescription("ScrobbleViewDelegate.touchMovedToPercentage(_, _)")
        
        // mocks
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(50, 0)
        scrobbleView!.enabled = true
        
        // runnable
        scrobbleView!.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrobbleView!.barView.bounds), 50.0)
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testTouchesMoved30() {
        /**
         expectations:
         - moves to 30% of the screen
         */
        
        // mocks
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(30, 0)
        scrobbleView!.enabled = true

        // runnable
        scrobbleView!.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrobbleView!.barView.bounds), 30.0)
    }
    
    func testTouchesMoved90() {
        /**
         expectations:
         - moves to 90% of the screen
         */
         
        // mocks
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(90, 0)
        scrobbleView!.enabled = true
        
        // runnable
        scrobbleView!.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrobbleView!.barView.bounds), 90.0)
    }
    
    func testTouchesMovedDisabled() {
        /**
         expectations:
         - touches don't execute
         */
         
        // mocks
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(90, 0)
        scrobbleView!.enabled = false
        
        // runnable
        scrobbleView!.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        // tests
        XCTAssertNotEqual(CGRectGetWidth(scrobbleView!.barView.bounds), 90.0)
    }
    
    func testTouchesEnded() {
        /**
        expectations:
        - delegate method called
        */
        scrobbleViewExpectation = expectationWithDescription("ScrobbleViewDelegate.touchEndedAtPercentage(_, _)")
        
        // mocks
        let mockTouch = UITouch()
        let mockEvent = UIEvent()
        scrobbleView!.enabled = true
        
        // runnable
        scrobbleView!.touchesEnded(Set(arrayLiteral: mockTouch), withEvent: mockEvent)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ScrobbleViewDelegate
extension ScrobbleViewTests: ScrobbleViewDelegate {
    func touchMovedToPercentage(sender: ScrobbleView, percentage: Float) {
        if let scrobbleViewExpectation = scrobbleViewExpectation {
            scrobbleViewExpectation.fulfill()
        }
    }
    
    func touchEndedAtPercentage(sender: ScrobbleView, percentage: Float) {
        if let scrobbleViewExpectation = scrobbleViewExpectation {
            scrobbleViewExpectation.fulfill()
        }
    }
}