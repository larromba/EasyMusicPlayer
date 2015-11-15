//
//  InfoViewTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
@testable import EasyMusic

class InfoViewTests: XCTestCase {
    var infoView: InfoView!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.

        infoView = InfoView()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSetTrackInfo() {
        let artist = "artist"
        let title = "title"
        let duration = 9.0
        let artwork = UIImage()
        let trackInfo = TrackInfo(artist: artist, title: title, duration: duration, artwork: artwork)
        
        infoView.setTrackInfo(trackInfo)
        
        XCTAssert(infoView.artist.text == artist)
        XCTAssert(infoView.track.text == title)
        XCTAssert(infoView.artwork.image == artwork)
    }
    
    func testClearTrackInfo() {
        infoView.artist.text = "artist"
        infoView.track.text = "title"
        infoView.time.text = "01:00:00"
        infoView.artwork.image = UIImage()
        
        infoView.clearTrackInfo()
        
        XCTAssert(infoView.artist.text == nil)
        XCTAssert(infoView.track.text == nil)
        XCTAssert(infoView.time.text == "00:00:00")
        XCTAssert(infoView.artwork.image == nil)
    }
    
    func testSetTime10Secs() {
        infoView.setTime(10, duration: 0)
        XCTAssert(infoView.time.text == "00:00:10")
    }
    
    func testSetTime10Mins() {
        infoView.setTime(10 * 60, duration: 0)
        XCTAssert(infoView.time.text == "00:10:00")
    }
    
    func testSetTime10Hrs() {
        infoView.setTime(10 * 60 * 60, duration: 0)
        XCTAssert(infoView.time.text == "10:00:00")
    }
}