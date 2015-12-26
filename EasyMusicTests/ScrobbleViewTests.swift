//
//  ScrubberViewTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
@testable import EasyMusic

private var analyticsExpectation: XCTestExpectation?
private var mockPoint: CGPoint!

class ScrubberViewTests: XCTestCase {
    private var scrubberView: ScrubberView?
    private var scrubberViewExpectation: XCTestExpectation?

    private class MockTouch : UITouch {
        override func locationInView(view: UIView?) -> CGPoint {
            return mockPoint
        }
    }
    
    override func setUp() {
        super.setUp()
        
        scrubberView = ScrubberView(frame: CGRectMake(0, 0, 100, 0))
        scrubberView!.delegate = self
    }
    
    override func tearDown() {
        super.tearDown()
        
        scrubberView = nil
        scrubberViewExpectation = nil
        analyticsExpectation = nil
        Analytics.__shared = Analytics()
    }
    
    func testAwakeFromNib() {
        /**
        expectations
        - scrubber view disabled
        */
        
        scrubberView!.awakeFromNib()
        XCTAssertFalse(scrubberView!.userInteractionEnabled)
    }
    
    func testScrubber50() {
        /**
        expectations:
        - moves to 50% of the screen
        */
        
        // runnable
        scrubberView!.scrubberToPercentage(0.5)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrubberView!.__barView.bounds), 50.0)
    }
    
    func testScrubber30() {
        /**
        expectations:
        - moves to 30% of the screen
        */
        
        // runnable
        scrubberView!.scrubberToPercentage(0.3)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrubberView!.__barView.bounds), 30.0)
    }
    
    func testScrubber90() {
        /**
        expectations:
        - moves to 90% of the screen
        */
        
        // runnable
        scrubberView!.scrubberToPercentage(0.9)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrubberView!.__barView.bounds), 90.0)
    }
    
    func testTouchesMoved50() {
        /**
         expectations:
         - moves to 50% of the screen
         - delegate called
         */
        scrubberViewExpectation = expectationWithDescription("ScrubberViewDelegate.touchMovedToPercentage(_, _)")
        
        // mocks
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPointMake(50, 0)
        
        // runnable
        scrubberView!.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrubberView!.__barView.bounds), 50.0)
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

        // runnable
        scrubberView!.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrubberView!.__barView.bounds), 30.0)
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
        
        // runnable
        scrubberView!.touchesMoved(Set([mockTouch]), withEvent: mockEvent)
        
        // tests
        XCTAssertEqual(CGRectGetWidth(scrubberView!.__barView.bounds), 90.0)
    }
    
    func testUserInteractionDisabledBarAlpha() {
        /**
         expectations:
         - bar's alpha value changes when disabled
         */
        
        // runnable
        scrubberView!.userInteractionEnabled = false
        
        // tests
        XCTAssertNotEqual(scrubberView!.__barView, 1.0)
    }
    
    func testTouchesEnded() {
        /**
        expectations:
        - delegate method called
        */
        scrubberViewExpectation = expectationWithDescription("ScrubberViewDelegate.touchEndedAtPercentage(_, _)")
        
        // mocks
        let mockTouch = UITouch()
        let mockEvent = UIEvent()
        
        // runnable
        scrubberView!.touchesEnded(Set(arrayLiteral: mockTouch), withEvent: mockEvent)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectationWithDescription("Analytics.shared.sendTimedAppEvent(_, _, _)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendTimedAppEvent(event: String, fromDate: NSDate, toDate: NSDate) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockTouch = UITouch()
        let mockEvent = UIEvent()
        
        // runnable
        scrubberView!.touchesBegan(Set(arrayLiteral: mockTouch), withEvent: mockEvent)
        scrubberView!.touchesEnded(Set(arrayLiteral: mockTouch), withEvent: mockEvent)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ScrubberViewDelegate

extension ScrubberViewTests: ScrubberViewDelegate {
    func touchMovedToPercentage(sender: ScrubberView, percentage: Float) {
        if let scrubberViewExpectation = scrubberViewExpectation {
            scrubberViewExpectation.fulfill()
        }
    }
    
    func touchEndedAtPercentage(sender: ScrubberView, percentage: Float) {
        if let scrubberViewExpectation = scrubberViewExpectation {
            scrubberViewExpectation.fulfill()
        }
    }
}