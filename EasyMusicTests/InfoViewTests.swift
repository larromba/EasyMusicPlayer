//
//  InfoViewTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import MediaPlayer
@testable import EasyMusic

class InfoViewTests: XCTestCase {
    var infoView: InfoView!
    
    override func setUp() {
        super.setUp()
        
        infoView = InfoView()
    }
    
    func testSetTrackInfo() {
        // mocks
        let artist = "artist"
        let title = "title"
        let duration = 9.0
        let artwork = UIImage()
        let url = NSURL(string: "")!
        let track = Track(artist: artist, title: title, duration: duration, artwork: artwork, url: url)
        
        // runnable
        infoView.setInfoFromTrack(track)
        
        // tests
        XCTAssert(MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo != nil)
        XCTAssert(infoView.artistLabel.text == artist)
        XCTAssert(infoView.trackLabel.text == title)
        XCTAssert(infoView.artworkImageView.image == artwork)
    }
    
    func testClearTrackInfo() {
        // mocks
        infoView.artistLabel.text = "artist"
        infoView.trackLabel.text = "title"
        infoView.timeLabel.text = "01:00:00"
        infoView.artworkImageView.image = UIImage()
        
        // runnable
        infoView.clearInfo()
        
        // tests
        XCTAssert(MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo == nil)
        XCTAssert(infoView.artistLabel.text == nil)
        XCTAssert(infoView.trackLabel.text == nil)
        XCTAssert(infoView.timeLabel.text == "00:00:00")
        XCTAssert(infoView.artworkImageView.image == nil)
    }
    
    func testSetTime10Secs() {
        // runnable
        infoView.setTime(10, duration: 0)
        
        // tests
        XCTAssert(infoView.timeLabel.text == "00:00:10")
    }
    
    func testSetTime10Mins() {
        // runnable
        infoView.setTime(10 * 60, duration: 0)
        
        // tests
        XCTAssert(infoView.timeLabel.text == "00:10:00")
    }
    
    func testSetTime10Hrs() {
        // runnable
        infoView.setTime(10 * 60 * 60, duration: 0)
        
        // tests
        XCTAssert(infoView.timeLabel.text == "10:00:00")
    }
}