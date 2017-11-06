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
    private enum Key: String {
        case tracks
        case currentTrackID
    }
    
    private var tracks: [MPMediaItem] = []
    private var trackIndex: Int = 0 {
        didSet {
            userDefaults.set(currentTrack.persistentID, forKey: Key.currentTrackID.rawValue)
            userDefaults.synchronize()
        }
    }
    private var userDefaults: UserDefaults = .standard
    private var MediaQueryType: MPMediaQuery.Type = MPMediaQuery.self
    
    var allTracks: [MPMediaItem] {
        return tracks
    }
    var currentResolvedTrack: Track {
        return Track(mediaItem: currentTrack)
    }
    var currentTrack: MPMediaItem {
        guard currentTrackNumber >= 0, currentTrackNumber < tracks.count else {
            return MPMediaItem() // safety
        }
        return tracks[currentTrackNumber]
    }
    var currentTrackNumber: Int {
        return trackIndex
    }
    var numOfTracks: Int {
        return tracks.count
    }
    var authorized: Bool {
        if #available(iOS 9.3, *) {
            return MPMediaLibrary.authorizationStatus() == .authorized
        }
        return true
    }
    
    func createPlaylist() -> [MPMediaItem] {
        guard authorized else {
            return []
        }
        
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

            if let songs = MediaQueryType.songs().items {
                return songs
            } else {
                return []
            }
            
        #endif
    }
    
    func authorize(_ completion: @escaping ((_ success: Bool) -> Void)) {
        if #available(iOS 9.3, *) {
            MPMediaLibrary.requestAuthorization({ (status: MPMediaLibraryAuthorizationStatus) in
                DispatchQueue.main.async(execute: {
                    completion(status == .authorized)
                })
            })
            return
        }
        completion(true)
    }
    
    func loadTracks() {
        guard authorized else {
            tracks = []
            trackIndex = 0
            return
        }
        guard
            let data = userDefaults.object(forKey: Key.tracks.rawValue) as? Data,
            let currentTrackID = userDefaults.object(forKey: Key.currentTrackID.rawValue) as? UInt64,
            let trackIDs = NSKeyedUnarchiver.unarchiveObject(with: data) as? [UInt64], trackIDs.count > 0 else {
            return
        }
        let query = MediaQueryType.songs()
        tracks = trackIDs.flatMap({ (id: UInt64) -> [MPMediaItem]? in
            let predicate = MPMediaPropertyPredicate(value: id, forProperty: MPMediaItemPropertyPersistentID)
            query.addFilterPredicate(predicate)
            let items = query.items
            query.removeFilterPredicate(predicate)
            return items
        }).reduce([], +)
        trackIndex = trackIDs.index(of: currentTrackID) ?? 0
    }
    
    func shuffleTracks() {
        guard authorized else {
            tracks = []
            trackIndex = 0
            return
        }
        
        // NSNotification.Name.MPMediaLibraryDidChange indicates when the music library changes, but an automatic refresh isn't required as we create a new playlist each time
        var playlist = createPlaylist()
        if playlist.count > 0 {
            for i in 0 ..< playlist.count-1 {
                let remainingCount = playlist.count - i;
                let exchangeIndex = i + Int(arc4random_uniform(UInt32(remainingCount)))
                playlist.swapAt(i, exchangeIndex)
            }
        }
        
        tracks = playlist
        trackIndex = 0
        saveTracks(tracks)
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
    
    func removeTrack(atIndex index: Int) {
        tracks.remove(at: index)
        trackIndex -= 1
    }
    
    // MARK: - Private
    
    private func saveTracks(_ tracks: [MPMediaItem]) {
        let trackIDs = tracks.map { return $0.persistentID }
        let data = NSKeyedArchiver.archivedData(withRootObject: trackIDs)
        userDefaults.set(data, forKey: Key.tracks.rawValue)
        userDefaults.synchronize()
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
    var __userDefaults: UserDefaults {
        get { return userDefaults }
        set { userDefaults = newValue }
    }
    var __MediaQueryType: MPMediaQuery.Type {
        get { return MediaQueryType }
        set { MediaQueryType = newValue }
    }
}
