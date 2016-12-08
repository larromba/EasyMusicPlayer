//
//  TrackManager.swift
//  EasyMusic
//
//  Created by Lee Arromba on 19/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation
import MediaPlayer

class TrackManager {
    fileprivate var tracks: [MPMediaItem] = []
    fileprivate var trackIndex: Int = 0
    
    var allTracks: [MPMediaItem] {
        return tracks
    }
    var currentResolvedTrack: Track {
        return Track(mediaItem: currentTrack)
    }
    var currentTrack: MPMediaItem {
        return tracks[currentTrackNumber]
    }
    var currentTrackNumber: Int {
        return trackIndex
    }
    var numOfTracks: Int {
        return tracks.count
    }
    
    func createPlaylist() -> [MPMediaItem] {
        #if (arch(i386) || arch(x86_64)) && os(iOS) // if simulator
            
            class MockMediaItem: MPMediaItem {
                let mediaItemArtwork = MPMediaItemArtwork(image: UIImage(named: "arkist-rendezvous-fill_your_coffee")!)
                let assetUrl = URL(fileURLWithPath: Constant.Path.DummyAudio)

                override var artist: String { return "Arkist" }
                override var title: String { return "Fill Your Coffee" }
                override var playbackDuration: TimeInterval { return 219 }
                override var artwork: MPMediaItemArtwork { return mediaItemArtwork }
                override var assetURL: URL { return assetUrl }
            }
            
            let tracks = [MockMediaItem(), MockMediaItem(), MockMediaItem()]
            return tracks
            
        #else // device

            if let songs = MPMediaQuery.songs().items {
                return songs
            } else {
                return []
            }
            
        #endif
    }
    
    func shuffleTracks() {
        let playlist = createPlaylist()
        let mItems = NSMutableArray(array: playlist)
        
        for i in 0 ..< mItems.count - 1 {
            let remainingCount = mItems.count - i;
            let exchangeIndex = i + Int(arc4random_uniform(UInt32(remainingCount)))
            mItems.exchangeObject(at: i, withObjectAt: exchangeIndex)
        }
        
        tracks = mItems as AnyObject as! [MPMediaItem]
        trackIndex = 0
    }
    
    func cuePrevious() -> Bool {
        let newIndex = currentTrackNumber - 1
        if newIndex < 0 {
            return false
        }
        
        trackIndex = newIndex
        return true
    }
    
    func cueNext() -> Bool {
        let newIndex = currentTrackNumber + 1
        if newIndex >= tracks.count {
            return false
        }
        
        trackIndex = newIndex
        return true
    }
    
    func cueStart() {
        trackIndex = 0
    }
    
    func cueEnd() {
        trackIndex = numOfTracks - 1
    }
}

// MARK: - Testing

extension TrackManager {
    var __trackIndex: Int {
        get { return trackIndex }
        set { trackIndex = newValue }
    }
    var __tracks: [MPMediaItem] {
        get { return tracks }
        set { tracks = newValue }
    }
}
