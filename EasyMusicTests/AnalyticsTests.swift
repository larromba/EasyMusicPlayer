//
//  AnalyticsTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 15/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import FirebaseAnalytics
@testable import EasyMusic

private var trackerExpectation: XCTestExpectation?

class AnalyticsTests: XCTestCase {
    private var analytics: EasyMusic.Analytics!
    
    class MockTracker: FirebaseAnalytics.Analytics {
        @objc override class func logEvent(_ name: String, parameters: [String: Any]?) -> () {
            trackerExpectation!.fulfill()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        analytics = Analytics(type: MockTracker.self, isSetup: true, sessionStartDate: Date())
    }
    
    override func tearDown() {
        analytics = nil
        trackerExpectation = nil
        
        super.tearDown()
    }
    
    func testStartSessionSendsEvent() {
        trackerExpectation = expectation(description: "FIRAnalytics.logEvent(_:, _:)")
        
        analytics.startSession()
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSessionSendsEvent() {
        trackerExpectation = expectation(description: "FIRAnalytics.logEvent(_:, _:)")
        
        analytics.endSession()
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSetupFailDoesntSendEvent() {
        let waitExpectation = expectation(description: "wait")
        
        class MockTrackerSetupFailed: MockTracker {
            @objc override class func logEvent(_ name: String, parameters: [String: Any]?) -> () {
                XCTFail()
            }
        }
        analytics = Analytics(type: MockTrackerSetupFailed.self, isSetup: false, sessionStartDate: Date())
        
        analytics.sendScreenNameEvent(AnalyticsTests.self)
        performAfterDelay(1) { () -> Void in
            waitExpectation.fulfill()
        }
        waitForExpectations(timeout: 2, handler: { error in XCTAssertNil(error) })
    }
    
    func testScreenNameSendsEvent() {
        trackerExpectation = expectation(description: "FIRAnalytics.logEvent(_:, _:)")
        
        analytics.sendScreenNameEvent(AnalyticsTests.self)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testButtonPressSendsEvent() {
        trackerExpectation = expectation(description: "FIRAnalytics.logEvent(_:, _:)")
        
        analytics.sendButtonPressEvent("", classId: AnalyticsTests.self)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testShareSendsEvent() {
        trackerExpectation = expectation(description: "FIRAnalytics.logEvent(_:, _:)")
        
        analytics.sendShareEvent("", classId: AnalyticsTests.self)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testAlertSendsEvent() {
        trackerExpectation = expectation(description: "FIRAnalytics.logEvent(_:, _:)")
        
        analytics.sendAlertEvent("", classId: AnalyticsTests.self)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testErrorSendsEvent() {
        trackerExpectation = expectation(description: "FIRAnalytics.logEvent(_:, _:)")
        
        let error = NSError(domain: "", code: 0, userInfo: nil)
        
        analytics.sendErrorEvent(error, classId: AnalyticsTests.self)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testSendTimedAppEvent() {
        trackerExpectation = expectation(description: "FIRAnalytics.logEvent(_:, _:)")
        
        analytics.sendTimedAppEvent("", fromDate: Date(), toDate: Date())
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}

