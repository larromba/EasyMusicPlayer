//
//  UserDataTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import MediaPlayer
@testable import EasyMusic

class UserDataTests: XCTestCase {
    var userData: UserData!

    override func setUp() {
        super.setUp()

        let userDefaults = UserDefaults(suiteName: "test")!
        userData = UserData(userDefaults: userDefaults)
    }

    override func tearDown() {
        userData = nil

        super.tearDown()
    }

    func testRepeatMode() {
        /**
         expectations
         - data is set
         */

        // mocks
        let expectedValue = MusicPlayer.RepeatMode.all

        // runnable
        userData.repeatMode = expectedValue

        // tests
        XCTAssertEqual(expectedValue, userData.repeatMode)
    }

    func testCurrentTrackID() {
        /**
         expectations
         - data is set
         */

        // mocks
        let expectedValue: MPMediaEntityPersistentID = 99888

        // runnable
        userData.currentTrackID = expectedValue

        // tests
        XCTAssertEqual(expectedValue, userData.currentTrackID)
    }

    func testTrackIDs() {
        /**
         expectations
         - data is set
         */

        // mocks
        let expectedValue: [MPMediaEntityPersistentID] = [99888, 12344]

        // runnable
        userData.trackIDs = expectedValue

        // tests
        XCTAssertEqual(expectedValue, userData.trackIDs!)
    }
}
