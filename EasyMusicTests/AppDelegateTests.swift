//
//  AppDelegateTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 09/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
@testable import EasyMusic

private var analyticsExpectation: XCTestExpectation?

class AppDelegateTests: XCTestCase {
    var appDelegate: AppDelegate?
    
    override func setUp() {
        super.setUp()
        
        appDelegate = AppDelegate()
    }
    
    override func tearDown() {
        super.tearDown()
        
        appDelegate = nil
        analyticsExpectation = nil
        Analytics._injectShared(Analytics())
    }
    
    func testSessionAnalytics() {
        /**
        expectations
        - analytics event sent
        */
        analyticsExpectation = expectationWithDescription("analytics.endSession()")
        
        // mocks
        class MockAnalytics: Analytics {
            var sessionStarted: Bool = false
            override func startSession() {
                sessionStarted = true
            }
            override func endSession() {
                if sessionStarted == true {
                    analyticsExpectation!.fulfill()
                }
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics._injectShared(mockAnalytics)
        
        let mockApplication = UIApplication.sharedApplication()
        
        // runnable
        appDelegate!.applicationWillEnterForeground(mockApplication)
        appDelegate!.applicationDidEnterBackground(mockApplication)
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}