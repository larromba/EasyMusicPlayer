//
//  TrackInfoTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
@testable import EasyMusic

class TrackInfoTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testInitValid() {
        let artist = "artist"
        let title = "title"
        let duration = 9.0
        let artwork = UIImage()
        let trackInfo = TrackInfo(artist: artist, title: title, duration: duration, artwork: artwork)
        
        XCTAssert(trackInfo.artist == artist)
        XCTAssert(trackInfo.title == title)
        XCTAssert(trackInfo.duration == duration)
        XCTAssert(trackInfo.artwork == artwork)
    }
}