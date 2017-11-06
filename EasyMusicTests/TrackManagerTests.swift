//
//  TrackManagerTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 24/11/2015.
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
private let mockAssetUrl = URL(fileURLWithPath: Constant.Path.DummyAudio)
private var mockTracks: [MPMediaItem]!

class TrackManagerTests: XCTestCase {
    private let url = URL(fileURLWithPath: Constant.Path.DummyAudio)
    private var trackManager: TrackManager?
    
    override func setUp() {
        super.setUp()
        
        class MockMediaItem: MPMediaItem {
            override var artist: String { return mockArtist }
            override var title: String { return mockTitle }
            override var playbackDuration: TimeInterval { return mockDuration }
            override var artwork: MPMediaItemArtwork { return mockArtwork }
            override var assetURL: URL { return mockAssetUrl }
        }
        
        class MockMediaItemNoArtistOrTitle: MPMediaItem {
            override var artist: String? { return nil }
            override var title: String? { return nil }
            override var playbackDuration: TimeInterval { return mockDuration }
            override var artwork: MPMediaItemArtwork { return mockArtwork }
            override var assetURL: URL { return mockAssetUrl }
        }
        
        mockTracks = [
            MockMediaItem(),
            MockMediaItem(),
            MockMediaItem(),
            MockMediaItemNoArtistOrTitle(),
            MockMediaItem(),
            MockMediaItem()
        ]
        
        trackManager = TrackManager()
        trackManager!.__tracks = mockTracks
    }
    
    override func tearDown() {
        trackManager = nil
        
        super.tearDown()
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
        for (index, element) in tracks.enumerated() {
            if element == mockTracks[index] {
                tracksInTheSameOrder = tracksInTheSameOrder + 1
            }
        }
        
        XCTAssert(tracksInTheSameOrder != mockTracks.count)
    }
    
    func testShuffleTracksNoMusic() {
        /**
         expectations
         - shuffle doesnt crash when there are no tracks
         */
        
        // mocks
        trackManager!.__tracks = []
        
        // runnable
        trackManager!.shuffleTracks()
        
        // tests
        XCTAssertTrue(true)
    }
    
    func testShuffleSavesTracks() {
        /**
         expectations
         - tracks save
         */
        
        // mocks
        class MockUserDefaults: UserDefaults {
            var didSetValue: Bool = false
            var didSynchronize: Bool = false
            var values: [UInt64] = []
            override func set(_ value: Any?, forKey defaultName: String) {
                if let value = value as? Data, let values = NSKeyedUnarchiver.unarchiveObject(with: value) as? [UInt64] {
                    self.values = values
                }
                didSetValue = true
            }
            override func synchronize() -> Bool {
                didSynchronize = true
                return true
            }
        }
        let userDefaults = MockUserDefaults()
        trackManager!.__userDefaults = userDefaults

        // runnable
        trackManager!.shuffleTracks()
        
        // tests
        XCTAssertTrue(userDefaults.didSetValue)
        XCTAssertTrue(userDefaults.didSynchronize)
        XCTAssertEqual(userDefaults.values.count, 3)
    }
    
    func testLoadTracks() {
        /**
         expectations
         - tracks load
         */
        
        // mocks
        let userDefaults = UserDefaults()
        userDefaults.set(NSKeyedArchiver.archivedData(withRootObject: [0, 1, 2]), forKey: "tracks")
        userDefaults.set(1, forKey: "currentTrackID")
        trackManager!.__userDefaults = userDefaults
        
        class MockMediaQuery: MPMediaQuery {
            var count = 0
            class MockMediaItem: MPMediaItem {
                var _persistentID: MPMediaEntityPersistentID = 0
                override var persistentID: MPMediaEntityPersistentID { return _persistentID }
            }
            override class func songs() -> MPMediaQuery {
                return MockMediaQuery()
            }
            override var items: [MPMediaItem]? {
                let item = MockMediaItem(); item._persistentID = MPMediaEntityPersistentID(count); count += 1
                return [item]
            }
        }
        trackManager!.__MediaQueryType = MockMediaQuery.self
        trackManager!.__tracks = []
        
        // runnable
        trackManager!.loadTracks()
        
        // tests
        XCTAssertEqual(trackManager!.allTracks.count, 3)
        XCTAssertEqual(trackManager!.currentTrack.persistentID, 1)
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
        let track = trackManager!.currentTrack
        
        // tests
        XCTAssertEqual(track, mockTracks[initialTrackIndex])
    }
    
    func testCurrentResolvedTrack() {
        /**
         expectations
         - current track resolved returned with artist and title populated
         */
         
         // mocks
        let initialTrackIndex = 3
        trackManager!.__trackIndex = initialTrackIndex
        
        // runnable
        let currentResolvedTrack = trackManager!.currentResolvedTrack

        // tests
        XCTAssertNotNil(currentResolvedTrack.artist)
        XCTAssertNotNil(currentResolvedTrack.title)
    }
    
    func testCurrentResolvedTrackIsCurrentTrack() {
        /**
         expectations
         - current track resolved returned with artist and title populated
         */
         
         // mocks
        let initialTrackIndex = 2
        trackManager!.__trackIndex = initialTrackIndex
        
        // runnable
        let currentTrack = trackManager!.currentTrack
        let currentResolvedTrack = trackManager!.currentResolvedTrack
        
        // tests
        XCTAssertEqual(currentTrack.title, currentResolvedTrack.title)
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
