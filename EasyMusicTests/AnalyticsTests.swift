//
//  AnalyticsTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 15/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import Google
@testable import EasyMusic

private var trackerExpectation: XCTestExpectation?

class AnalyticsTests: XCTestCase {
    private var analytics: Analytics?
    
    class MockTracker: NSObject, GAITracker {
        @objc var name: String! = ""
        @objc var allowIDFACollection: Bool = false
        override init() { }
        @objc func set(parameterName: String!, value: String!) { }
        @objc func get(parameterName: String!) -> String! { return "" }
        @objc func send(parameters: [NSObject : AnyObject]!) {
            trackerExpectation!.fulfill()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        analytics = Analytics()
        _ = try! analytics!.setup()
        analytics!.dryRun = true
    }
    
    override func tearDown() {
        super.tearDown()
        
        analytics = nil
        trackerExpectation = nil
    }
    
    func testSetup() {
        do {
            try analytics!.setup()
        } catch _ {
            XCTFail()
        }
    }
    
    func testSessionSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectationWithDescription("GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        // runnable
        analytics!.startSession()
        analytics!.endSession()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSetupFailDoesntSendEvent() {
        /**
        expectations
        - analytics doesnt event sent
        */
        let waitExpectation = expectationWithDescription("wait")
        
        // mocks
        class MockTrackerSetupFailed: MockTracker {
            override func send(parameters: [NSObject : AnyObject]!) {
                XCTFail()
            }
        }
        
        let mockTracker = MockTrackerSetupFailed()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        
        analytics!.__isSetup = false
        
        // runnable
        analytics!.sendScreenNameEvent(mockEvent)
        performAfterDelay(1) { () -> Void in
            waitExpectation.fulfill()
        }
        
        // tests
        waitForExpectationsWithTimeout(2, handler: { error in XCTAssertNil(error) })
    }
    
    func testScreenNameSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectationWithDescription("GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        
        // runnable
        analytics!.sendScreenNameEvent(mockEvent)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testButtonPressSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectationWithDescription("GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        let mockClassId = ""
        
        // runnable
        analytics!.sendButtonPressEvent(mockEvent, classId: mockClassId)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testShareSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectationWithDescription("GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        let mockClassId = ""
        
        // runnable
        analytics!.sendShareEvent(mockEvent, classId: mockClassId)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAlertSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectationWithDescription("GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        let mockClassId = ""
        
        // runnable
        analytics!.sendAlertEvent(mockEvent, classId: mockClassId)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
    
    func testErrorSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectationWithDescription("GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockError = NSError(domain: "", code: 0, userInfo: nil)
        let mockClassId = ""
        
        // runnable
        analytics!.sendErrorEvent(mockError, classId: mockClassId)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}