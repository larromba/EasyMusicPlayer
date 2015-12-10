//
//  UserDataTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
@testable import EasyMusic

class UserDataTests: XCTestCase {
    func testRepeatMode() {
        /**
         expectations
         - data is set
         */
        
        // mocks
        let expectedValue = MusicPlayerRepeatMode.All
        
        // runnable
        UserData.repeatMode = expectedValue
        
        // tests
        XCTAssertEqual(expectedValue, UserData.repeatMode)
    }
}