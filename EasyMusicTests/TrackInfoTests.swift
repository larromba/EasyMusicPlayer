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

private let mockArtist = "artist"
private let mockTitle = "title"
private let mockDuration = 9.0
private let mockImage = UIImage()
private let mockArtwork = MPMediaItemArtwork(image: mockImage)
private let mockAssetUrl = NSURL(string: "")!

class TrackInfoTests: XCTestCase {
    func testInitValid() {
        /**
         expectations:
         - object properties are initialised correctly
         */
        
        // mocks
        class MockMediaItem: MPMediaItem {
            override var artist: String { return mockArtist }
            override var title: String { return mockTitle }
            override var playbackDuration: NSTimeInterval { return mockDuration }
            override var artwork: MPMediaItemArtwork { return mockArtwork }
            override var assetURL: NSURL { return mockAssetUrl }
        }
        
        // runnable
        let track = Track(mediaItem: MockMediaItem())
        
        // tests
        XCTAssertEqual(track.artist, mockArtist)
        XCTAssertEqual(track.title, mockTitle)
        XCTAssertEqual(track.duration, mockDuration)
        XCTAssertEqual(track.artwork, mockImage)
        XCTAssertEqual(track.url, mockAssetUrl)
    }
}