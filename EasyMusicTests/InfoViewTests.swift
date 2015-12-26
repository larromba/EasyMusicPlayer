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

private let mockArtist = "artist"
private let mockTitle = "title"
private let mockDuration = 9.0
private let mockImage = UIImage()
private let mockArtwork = MPMediaItemArtwork(image: mockImage)
private let mockAssetUrl = NSURL(string: "")!

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
        class MockMediaItem: MPMediaItem {
            override var artist: String { return mockArtist }
            override var title: String { return mockTitle }
            override var playbackDuration: NSTimeInterval { return mockDuration }
            override var artwork: MPMediaItemArtwork { return mockArtwork }
            override var assetURL: NSURL { return mockAssetUrl }
        }
        
        let track = Track(mediaItem: MockMediaItem())
        
        // runnable
        infoView!.setInfoFromTrack(track)
        
        // tests
        XCTAssertNotNil(MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo)
        XCTAssertEqual(infoView!.artistLabel.text, mockArtist)
        XCTAssertEqual(infoView!.trackLabel.text, mockTitle)
        XCTAssertEqual(infoView!.artworkImageView.image, mockImage)
    }
    
    func testSetTrackPosition() {
        /**
        expectations:
        - track position set correctly in ui
        */
        
        // runnable
        let trackPosition = 2
        let totalTracks = 3
        infoView!.setTrackPosition(trackPosition, totalTracks: totalTracks)
        
        // tests
        let firstCharacter = String(infoView!.trackPositionLabel.text!.characters.first!)
        let lastCharacter = String(infoView!.trackPositionLabel.text!.characters.last!)
        XCTAssertEqual(Int(firstCharacter), trackPosition)
        XCTAssertEqual(Int(lastCharacter), totalTracks)
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