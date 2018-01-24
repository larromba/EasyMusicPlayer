//
//  UserData.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation
import MediaPlayer

class UserData {
    private enum Key: String {
        case repeatMode
        case tracks
        case currentTrackID
    }
    
    private var userDefaults: UserDefaults
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    var repeatMode: MusicPlayer.RepeatMode? {
        get {
            if let repeatModeData = userDefaults.object(forKey: Key.repeatMode.rawValue) as? NSNumber {
                return MusicPlayer.RepeatMode(rawValue: repeatModeData.intValue)
            }
            return nil
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: Key.repeatMode.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var currentTrackID: MPMediaEntityPersistentID? {
        get {
            return userDefaults.object(forKey: Key.currentTrackID.rawValue) as? MPMediaEntityPersistentID
        }
        set {
            userDefaults.set(newValue, forKey: Key.currentTrackID.rawValue)
            userDefaults.synchronize()
        }
    }
    
    var trackIDs: [MPMediaEntityPersistentID]? {
        get {
            if let data = userDefaults.object(forKey: Key.tracks.rawValue) as? Data {
                return NSKeyedUnarchiver.unarchiveObject(with: data) as? [MPMediaEntityPersistentID]
            }
            return nil
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue ?? [])
            userDefaults.set(data, forKey: Key.tracks.rawValue)
            userDefaults.synchronize()
        }
    }
}
