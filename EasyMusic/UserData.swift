//
//  UserData.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

class UserData {
    class var repeatMode: MusicPlayer.RepeatMode? {
        get {
            if let repeatModeData = UserDefaults.standard.object(forKey: "repeatMode") as? NSNumber {
                return MusicPlayer.RepeatMode(rawValue: repeatModeData.intValue)
            }
            return nil
        }
        set {
            var repeatModeData: NSNumber?
            if newValue != nil {
                repeatModeData = NSNumber(value: newValue!.rawValue as Int)
            }
            UserDefaults.standard.set(repeatModeData, forKey: "repeatMode")
        }
    }
}
