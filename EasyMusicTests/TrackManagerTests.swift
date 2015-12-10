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
        trackManager!._injectTracks(mockTracks)
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
        trackManager!._injectTrackIndex(initialTrackIndex)
        
        // runnable
        let result =  trackManager!.cuePrevious()
        
        // tests
        XCTAssert(trackManager!.currentTrackNumber == (initialTrackIndex - 1))
        XCTAssert(result == true)
    }
    
    func testCuePreviousIsntNegative() {
        /**
         expectations
         - previous track doesnt go < 0
         */
        
        // mocks
        let initialTrackIndex = 0
        trackManager!._injectTrackIndex(initialTrackIndex)
        
        // runnable
        let result = trackManager!.cuePrevious()
        
        // tests
        XCTAssert(result == false)
    }
    
    func testCueNext() {
        /**
         expectations
         - next track is cued
         */
        
        // mocks
        let initialTrackIndex = 3
        trackManager!._injectTrackIndex(initialTrackIndex)
        
        // runnable
        let result = trackManager!.cueNext()
        
        // tests
        XCTAssert(trackManager!.currentTrackNumber == (initialTrackIndex + 1))
        XCTAssert(result == true)
    }
    
    func testCueNextNoBufferOverride() {
        /**
         expectations
         - next track doesnt go > tracks.count
         */
        
        // mocks
        let initialTrackIndex = mockTracks.count
        trackManager!._injectTrackIndex(initialTrackIndex)
        
        // runnable
        let result = trackManager!.cueNext()
        
        // tests
        XCTAssert(result == false)
    }
    
    func testCueRestart() {
        /**
         expectations
         - manager cued to start from the beginning
         */
         
         // mocks
        let initialTrackIndex = 3
        trackManager!._injectTrackIndex(initialTrackIndex)
        
        let expectedResult = 0
        
        // runnable
        trackManager!.cueRestart()
        
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
        XCTAssert(tracks == mockTracks)
    }
    
    func testCurrentTrack() {
        /**
         expectations
         - current track returned
         */
        
        // mocks
        let initialTrackIndex = 3
        trackManager!._injectTrackIndex(initialTrackIndex)
        
        // runnable
        let tracks = trackManager!.allTracks
        
        // tests
        XCTAssert(tracks[initialTrackIndex] == mockTracks[initialTrackIndex])
    }
    
    func testCurrentTrackNumber() {
        /**
         expectations
         - current track number is correct
         */
        
        // mocks
        let initialTrackIndex = 3
        trackManager!._injectTrackIndex(initialTrackIndex)
        
        // runnable
        let trackNumber = trackManager!.currentTrackNumber
        
        // tests
        XCTAssert(trackNumber == initialTrackIndex)
    }
    
    func testNumOfTracks() {
        /**
         expectations
         - number of tracks is correct
         */
        
        // runnable
        let numberOfTracks = trackManager!.numOfTracks
        
        // tests
        XCTAssert(numberOfTracks == mockTracks.count)
    }
}