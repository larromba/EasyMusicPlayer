//
//  UserData.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

class UserData {
    class var repeatMode: MusicPlayerRepeatMode? {
        get {
            if let repeatModeData = NSUserDefaults.standardUserDefaults().objectForKey("repeatMode") as? NSNumber {
                return MusicPlayerRepeatMode(rawValue: repeatModeData.integerValue)
            }
            return nil
        }
        set {
            var repeatModeData: NSNumber?
            if newValue != nil {
                repeatModeData = NSNumber(integer: newValue!.rawValue)
            }
            NSUserDefaults.standardUserDefaults().setObject(repeatModeData, forKey: "repeatMode")
        }
    }
}