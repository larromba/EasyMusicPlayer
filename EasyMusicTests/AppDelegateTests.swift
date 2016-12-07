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
        appDelegate = nil
        analyticsExpectation = nil
        Analytics.__shared = Analytics()
        try? Analytics.__shared.setup()
        
        super.tearDown()
    }
    
    func testStartSession1() {
        /**
        expectations
        - session started
        */
        analyticsExpectation = expectation(description: "analytics.startSession()")
        
        // mocks
        class MockAnalytics: Analytics {
            override func startSession() {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockApplication = UIApplication.shared
        
        // runnable
        appDelegate!.applicationWillEnterForeground(mockApplication)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testStartSession2() {
        /**
        expectations
        - session started
        */
        analyticsExpectation = expectation(description: "analytics.startSession()")
        
        // mocks
        class MockAnalytics: Analytics {
            override func startSession() {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockApplication = UIApplication.shared
        
        // runnable
        let didFinish = appDelegate!.application(mockApplication, didFinishLaunchingWithOptions: nil)
        
        // tests
        XCTAssertTrue(didFinish)
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
    
    func testEndSession() {
        /**
        expectations
        - session ended
        */
        analyticsExpectation = expectation(description: "analytics.endSession()")
        
        // mocks
        class MockAnalytics: Analytics {
            override func endSession() {
                analyticsExpectation!.fulfill()
            }
        }
        
        let mockAnalytics = MockAnalytics()
        Analytics.__shared = mockAnalytics
        
        let mockApplication = UIApplication.shared
        
        // runnable
        appDelegate!.applicationDidEnterBackground(mockApplication)
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}
