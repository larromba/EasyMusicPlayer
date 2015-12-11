//
//  TrackManagerTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 24/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
@testable import EasyMusic

class TrackManagerTests: XCTestCase {
    private let url = NSURL(fileURLWithPath: Constant.Path.DummyAudio)

    private var trackManager: TrackManager?
    private var mockTracks: [Track]!
    
    override func setUp() {
        super.setUp()
        
        mockTracks = [
            Track(artist: "Artist 1", title: "Title 1", duration: 219, artwork: nil, url: url),
            Track(artist: "Artist 2", title: "Title 2", duration: 219, artwork: nil, url: url),
            Track(artist: "Artist 3", title: "Title 3", duration: 219, artwork: nil, url: url),
            Track(artist: "Artist 4", title: "Title 4", duration: 219, artwork: nil, url: url),
            Track(artist: "Artist 5", title: "Title 5", duration: 219, artwork: nil, url: url),
            Track(artist: "Artist 6", title: "Title 6", duration: 219, artwork: nil, url: url)
        ]
        
        trackManager = TrackManager()
        trackManager!.__tracks = mockTracks
    }
    
    override func tearDown() {
        super.tearDown()
        
        trackManager = nil
    }
    
    func testShuffleTracks() {
        /**
        expectations
        - tracks shuffle
        */
        
        // runnable
        trackManager!.shuffleTracks()
        
        // tests
        let tracks = trackManager!.allTracks
        var tracksInTheSameOrder = 0
        for (index, element) in tracks.enumerate() {
            if element == mockTracks[index] {
                tracksInTheSameOrder = tracksInTheSameOrder + 1
            }
        }
        
        XCTAssert(tracksInTheSameOrder != mockTracks.count)
    }
    
    func testCuePrevious() {
        /**
         expectations
         - previous track is cued
         */
        
        // mocks
        let initialTrackIndex = 3
        trackManager!.__trackIndex = initialTrackIndex
        
        // runnable
        let result =  trackManager!.cuePrevious()
        
        // tests
        XCTAssertEqual(trackManager!.currentTrackNumber, (initialTrackIndex - 1))
        XCTAssertTrue(result)
    }
    
    func testCuePreviousIsntNegative() {
        /**
         expectations
         - previous track doesnt go < 0
         */
        
        // mocks
        let initialTrackIndex = 0
        trackManager!.__trackIndex = initialTrackIndex
        
        // runnable
        let result = trackManager!.cuePrevious()
        
        // tests
        XCTAssertFalse(result)
    }
    
    func testCueNext() {
        /**
         expectations
         - next track is cued
         */
        
        // mocks
        let initialTrackIndex = 3
        trackManager!.__trackIndex = initialTrackIndex
        
        // runnable
        let result = trackManager!.cueNext()
        
        // tests
        XCTAssertEqual(trackManager!.currentTrackNumber, (initialTrackIndex + 1))
        XCTAssertTrue(result)
    }
    
    func testCueNextNoBufferOverride() {
        /**
         expectations
         - next track doesnt go > tracks.count
         */
        
        // mocks
        let initialTrackIndex = mockTracks.count
        trackManager!.__trackIndex = initialTrackIndex
        
        // runnable
        let result = trackManager!.cueNext()
        
        // tests
        XCTAssertFalse(result)
    }
    
    func testCueStart() {
        /**
         expectations
         - manager cued to start from the beginning
         */
         
         // mocks
        let initialTrackIndex = 3
        trackManager!.__trackIndex = initialTrackIndex
        
        let expectedResult = 0
        
        // runnable
        trackManager!.cueStart()
        
        // tests
        XCTAssertEqual(trackManager!.currentTrackNumber, expectedResult)
    }
    
    func testCueEnd() {
        /**
         expectations
         - manager cued to start from the end
         */
         
         // mocks
        let initialTrackIndex = 0
        trackManager!.__trackIndex = initialTrackIndex
        
        let expectedResult = trackManager!.numOfTracks - 1
        
        // runnable
        trackManager!.cueEnd()
        
        // tests
        XCTAssertEqual(trackManager!.currentTrackNumber, expectedResult)
    }
    
    func testAllTracks() {
        /**
         expectations
         - all tracks returned
         */
        
        // runnable
        let tracks = trackManager!.allTracks
        
        // tests
        XCTAssertEqual(tracks, mockTracks)
    }
    
    func testCurrentTrack() {
        /**
         expectations
         - current track returned
         */
        
        // mocks
        let initialTrackIndex = 3
        trackManager!.__trackIndex = initialTrackIndex
        
        // runnable
        let tracks = trackManager!.allTracks
        
        // tests
        XCTAssertEqual(tracks[initialTrackIndex], mockTracks[initialTrackIndex])
    }
    
    func testCurrentTrackNumber() {
        /**
         expectations
         - current track number is correct
         */
        
        // mocks
        let initialTrackIndex = 3
        trackManager!.__trackIndex = initialTrackIndex
        
        // runnable
        let trackNumber = trackManager!.currentTrackNumber
        
        // tests
        XCTAssertEqual(trackNumber, initialTrackIndex)
    }
    
    func testNumOfTracks() {
        /**
         expectations
         - number of tracks is correct
         */
        
        // runnable
        let numberOfTracks = trackManager!.numOfTracks
        
        // tests
        XCTAssertEqual(numberOfTracks, mockTracks.count)
    }
}