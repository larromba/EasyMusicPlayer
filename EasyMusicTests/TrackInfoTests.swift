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
    func testInitValid() {
        let artist = "artist"
        let title = "title"
        let duration = 9.0
        let artwork = UIImage()
        let url = NSURL(string: "")!
        let track = Track(artist: artist, title: title, duration: duration, artwork: artwork, url: url)
        
        XCTAssert(track.artist == artist)
        XCTAssert(track.title == title)
        XCTAssert(track.duration == duration)
        XCTAssert(track.artwork == artwork)
        XCTAssert(track.url == url)
    }
}