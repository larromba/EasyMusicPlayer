//
//  TrackInfoTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import MediaPlayer
@testable import EasyMusic

class TrackInfoTests: XCTestCase {
    func testInitValid() {
        /**
         expectations:
         - object properties are initialised correctly
         */
        
        // mocks
        let artist = "artist"
        let title = "title"
        let duration = 9.0
        let image = UIImage()
        let artwork = MPMediaItemArtwork(image: image)
        let url = NSURL(string: "")!
        
        // runnable
        let track = Track(artist: artist, title: title, duration: duration, mediaItemArtwork: artwork, url: url)
        
        // tests
        XCTAssertEqual(track.artist, artist)
        XCTAssertEqual(track.title, title)
        XCTAssertEqual(track.duration, duration)
        XCTAssertEqual(track.artwork, image)
        XCTAssertEqual(track.url, url)
    }
}