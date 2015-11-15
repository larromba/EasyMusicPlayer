//
//  TracksTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
@testable import EasyMusic

class MockTrackInfo : TrackInfo {
    init() {
        super.init(artist: nil, title: nil, duration: 0.0, artwork: nil)
    }
}

class TracksTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitValid() {
        let trackInfo = MockTrackInfo()
        let trackIndex = 1
        let totalTracks = 2
        let tracksInfo = TracksInfo(trackInfo: trackInfo, trackIndex: trackIndex, totalTracks: totalTracks)
        
        XCTAssert(tracksInfo.trackInfo == trackInfo)
        XCTAssert(tracksInfo.trackIndex == trackIndex)
        XCTAssert(tracksInfo.totalTracks == totalTracks)
    }
}