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
        override func location(in view: UIView?) -> CGPoint {
            return mockPoint
        }
    }
    
    override func setUp() {
        super.setUp()
        
        scrubberView = ScrubberView(frame: CGRect(x: 0, y: 0, width: 100, height: 0))
        scrubberView!.delegate = self
    }
    
    override func tearDown() {
        scrubberView = nil
        scrubberViewExpectation = nil
        analyticsExpectation = nil
        Analytics.__shared = Analytics()
        
        super.tearDown()
    }
    
    func testAwakeFromNib() {
        /**
        expectations
        - scrubber view disabled
        */
        
        scrubberView!.awakeFromNib()
        XCTAssertFalse(scrubberView!.isUserInteractionEnabled)
    }
    
    func testScrubber50() {
        /**
        expectations:
        - moves to 50% of the screen
        */
        
        // runnable
        scrubberView!.scrubberToPercentage(0.5)
        
        // tests
        XCTAssertEqual((scrubberView!.__barView.bounds).width, 50.0)
    }
    
    func testScrubber30() {
        /**
        expectations:
        - moves to 30% of the screen
        */
        
        // runnable
        scrubberView!.scrubberToPercentage(0.3)
        
        // tests
        XCTAssertEqual((scrubberView!.__barView.bounds).width, 30.0)
    }
    
    func testScrubber90() {
        /**
        expectations:
        - moves to 90% of the screen
        */
        
        // runnable
        scrubberView!.scrubberToPercentage(0.9)
        
        // tests
        XCTAssertEqual((scrubberView!.__barView.bounds).width, 90.0)
    }
    
    func testTouchesMoved50() {
        /**
         expectations:
         - moves to 50% of the screen
         - delegate called
         */
        scrubberViewExpectation = expectation(description: "ScrubberViewDelegate.touchMovedToPercentage(_, _)")
        
        // mocks
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPoint(x: 50, y: 0)
        
        // runnable
        scrubberView!.touchesMoved(Set([mockTouch]), with: mockEvent)
        
        // tests
        XCTAssertEqual((scrubberView!.__barView.bounds).width, 50.0)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testTouchesMoved30() {
        /**
         expectations:
         - moves to 30% of the screen
         */
        
        // mocks
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPoint(x: 30, y: 0)

        // runnable
        scrubberView!.touchesMoved(Set([mockTouch]), with: mockEvent)
        
        // tests
        XCTAssertEqual((scrubberView!.__barView.bounds).width, 30.0)
    }
    
    func testTouchesMoved90() {
        /**
         expectations:
         - moves to 90% of the screen
         */
         
        // mocks
        let mockTouch = MockTouch()
        let mockEvent = UIEvent()
        mockPoint = CGPoint(x: 90, y: 0)
        
        // runnable
        scrubberView!.touchesMoved(Set([mockTouch]), with: mockEvent)
        
        // tests
        XCTAssertEqual((scrubberView!.__barView.bounds).width, 90.0)
    }
    
    func testUserInteractionDisabledBarAlpha() {
        /**
         expectations:
         - bar's alpha value changes when disabled
         */
        
        // runnable
        scrubberView!.isUserInteractionEnabled = false
        
        // tests
        XCTAssertNotEqual(scrubberView!.__barView.alpha, 1.0)
    }
    
    func testTouchesEnded() {
        /**
        expectations:
        - delegate method called
        */
        scrubberViewExpectation = expectation(description: "ScrubberViewDelegate.touchEndedAtPercentage(_, _)")
        
        // mocks
        let mockTouch = UITouch()
        let mockEvent = UIEvent()
        
        // runnable
        scrubberView!.touchesEnded(Set(arrayLiteral: mockTouch), with: mockEvent)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectation(description: "Analytics.shared.sendTimedAppEvent(_, _, _)")
        
        // mocks
        class MockAnalytics: Analytics {
            override func sendTimedAppEvent(_ event: String, fromDate: Date, toDate: Date) {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockTouch = UITouch()
        let mockEvent = UIEvent()
        
        // runnable
        scrubberView!.touchesBegan(Set(arrayLiteral: mockTouch), with: mockEvent)
        scrubberView!.touchesEnded(Set(arrayLiteral: mockTouch), with: mockEvent)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}

// MARK: - ScrubberViewDelegate

extension ScrubberViewTests: ScrubberViewDelegate {
    func touchMovedToPercentage(_ sender: ScrubberView, percentage: Float) {
        if let scrubberViewExpectation = scrubberViewExpectation {
            scrubberViewExpectation.fulfill()
        }
    }
    
    func touchEndedAtPercentage(_ sender: ScrubberView, percentage: Float) {
        if let scrubberViewExpectation = scrubberViewExpectation {
            scrubberViewExpectation.fulfill()
        }
    }
}
