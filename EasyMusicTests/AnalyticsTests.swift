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
    fileprivate var analytics: Analytics?
    
    class MockTracker: NSObject, GAITracker {
        @objc var name: String! = ""
        @objc var allowIDFACollection: Bool = false
        override init() { }
        @objc func set(_ parameterName: String!, value: String!) { }
        @objc func get(_ parameterName: String!) -> String! { return "" }
        @objc func send(_ parameters: [AnyHashable: Any]!) {
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
        analytics = nil
        trackerExpectation = nil
        
        super.tearDown()
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
        trackerExpectation = expectation(description: "GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        // runnable
        analytics!.startSession()
        analytics!.endSession()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSetupFailDoesntSendEvent() {
        /**
        expectations
        - analytics doesnt event sent
        */
        let waitExpectation = expectation(description: "wait")
        
        // mocks
        class MockTrackerSetupFailed: MockTracker {
            override func send(_ parameters: [AnyHashable: Any]!) {
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
        waitForExpectations(timeout: 2, handler: { error in XCTAssertNil(error) })
    }
    
    func testScreenNameSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectation(description: "GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        
        // runnable
        analytics!.sendScreenNameEvent(mockEvent)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testButtonPressSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectation(description: "GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        let mockClassId = ""
        
        // runnable
        analytics!.sendButtonPressEvent(mockEvent, classId: mockClassId)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testShareSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectation(description: "GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        let mockClassId = ""
        
        // runnable
        analytics!.sendShareEvent(mockEvent, classId: mockClassId)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAlertSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectation(description: "GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        let mockClassId = ""
        
        // runnable
        analytics!.sendAlertEvent(mockEvent, classId: mockClassId)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testErrorSendsEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectation(description: "GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockError = NSError(domain: "", code: 0, userInfo: nil)
        let mockClassId = ""
        
        // runnable
        analytics!.sendErrorEvent(mockError, classId: mockClassId)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSendTimedAppEvent() {
        /**
        expectations
        - analytics event sent
        */
        trackerExpectation = expectation(description: "GAITracker.send(_)")
        
        // mocks
        let mockTracker = MockTracker()
        analytics!.__defaultTracker = mockTracker
        
        let mockEvent = ""
        let mockFromDate = Date()
        let mockToDate = Date()
        
        // runnable
        analytics!.sendTimedAppEvent(mockEvent, fromDate: mockFromDate, toDate: mockToDate)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}
