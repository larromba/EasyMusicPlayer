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
    private var tracks: [Track] = []
    private var trackIndex: Int = 0
    
    var allTracks: [Track] {
        return tracks
    }
    var currentTrack: Track {
        return tracks[currentTrackNumber]
    }
    var currentTrackNumber: Int {
        return trackIndex
    }
    var numOfTracks: Int {
        return tracks.count
    }
    
    func createPlaylist() -> [Track] {
        #if (arch(i386) || arch(x86_64)) && os(iOS) // if simulator
            
            let url = NSURL(fileURLWithPath: Constant.Path.DummyAudio)
            let tracks = [
                Track(artist: "Artist 1", title: "Title 1", duration: 219, artwork: nil, url: url),
                Track(artist: "Artist 2", title: "Title 2", duration: 219, artwork: nil, url: url),
                Track(artist: "Artist 3", title: "Title 3", duration: 219, artwork: nil, url: url)]
            return tracks
            
        #else // device
            
            var tracks: [Track] = []
            let songs = MPMediaQuery.songsQuery().items
            for song: MPMediaItem in songs! {
                var artwork: UIImage? = nil
                if let songArtwork = song.artwork {
                    artwork = songArtwork.imageWithSize(CGSizeMake(512, 512))
                }
                
                if let urlProperty = song.assetURL {
                    let track = Track(
                        artist: song.artist,
                        title: song.title,
                        duration: song.playbackDuration,
                        artwork: artwork,
                        url: urlProperty)
                    
                    tracks.append(track)
                }
            }
            
            return tracks
            
        #endif
    }
    
    func shuffleTracks() {
        let playlist = createPlaylist()
        let mItems = NSMutableArray(array: playlist)
        
        for var i = 0; i < mItems.count - 1; ++i {
            let remainingCount = mItems.count - i;
            let exchangeIndex = i + Int(arc4random_uniform(UInt32(remainingCount)))
            mItems.exchangeObjectAtIndex(i, withObjectAtIndex: exchangeIndex)
        }
        
        tracks = mItems as AnyObject as! [Track]
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
    var __tracks: [Track] {
        get { return tracks }
        set { tracks = newValue }
    }
}