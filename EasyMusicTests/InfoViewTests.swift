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
    private var infoView: InfoView?
    
    override func setUp() {
        super.setUp()
        
        infoView = InfoView()
    }
    
    override func tearDown() {
        super.tearDown()
        
        infoView = nil
    }
    
    func testSetTrackInfo() {
        /**
         expectations:
         - information strings set correctly from track in ui
         */
        
        // mocks
        let artist = "artist"
        let title = "title"
        let duration = 9.0
        let image = UIImage()
        let artwork = MPMediaItemArtwork(image: image)
        let url = NSURL(string: "")!
        let track = Track(artist: artist, title: title, duration: duration, mediaItemArtwork: artwork, url: url)
        
        // runnable
        infoView!.setInfoFromTrack(track)
        
        // tests
        XCTAssertNotNil(MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo)
        XCTAssertEqual(infoView!.artistLabel.text, artist)
        XCTAssertEqual(infoView!.trackLabel.text, title)
        XCTAssertEqual(infoView!.artworkImageView.image, image)
    }
    
    func testSetTrackPosition() {
        /**
        expectations:
        - track position set correctly in ui
        */
        
        // runnable
        infoView!.setTrackPosition(2, totalTracks: 3)
        
        // tests
        XCTAssertEqual(infoView!.trackPositionLabel.text, "2 of 3")
    }
    
    func testClearTrackInfo() {
        /**
        expectations:
        - ui clears
        */
        
        // mocks
        infoView!.artistLabel.text = "artist"
        infoView!.trackLabel.text = "title"
        infoView!.trackPositionLabel.text = "1 of 1"
        infoView!.timeLabel.text = "01:00:00"
        infoView!.artworkImageView.image = UIImage()
        
        // runnable
        infoView!.clearInfo()
        
        // tests
        XCTAssertNil(MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo)
        XCTAssertNil(infoView!.artistLabel.text)
        XCTAssertNil(infoView!.trackLabel.text)
        XCTAssertNil(infoView!.trackPositionLabel.text)
        XCTAssertEqual(infoView!.timeLabel.text, "00:00:00")
        XCTAssertNil(infoView!.artworkImageView.image)
    }
    
    func testSetTime10Secs() {
        /**
        expectations:
        - time set correctly in ui
        */
        
        // runnable
        infoView!.setTime(10, duration: 0)
        
        // tests
        XCTAssertEqual(infoView!.timeLabel.text, "00:00:10")
    }
    
    func testSetTime10Mins() {
        /**
        expectations:
        - time set correctly in ui
        */
        
        // runnable
        infoView!.setTime(10 * 60, duration: 0)
        
        // tests
        XCTAssertEqual(infoView!.timeLabel.text, "00:10:00")
    }
    
    func testSetTime10Hrs() {
        /**
        expectations:
        - time set correctly in ui
        */
        
        // runnable
        infoView!.setTime(10 * 60 * 60, duration: 0)
        
        // tests
        XCTAssertEqual(infoView!.timeLabel.text, "10:00:00")
    }
}