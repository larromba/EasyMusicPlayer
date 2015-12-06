//
//  Constants.swift
//  EasyMusic
//
//  Created by Lee Arromba on 15/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

struct Constant {
    struct Notification {
        static let ApplicationDidBecomeActive = "applicationDidBecomeActive"
        static let ApplicationWillResignActive = "applicationWillResignActive"
        static let ApplicationWillTerminate = "applicationWillTerminate"
    }
    
    struct Bundle {
        static let BundleDisplayName = "CFBundleName"
        static let BundleIdentifier = "CFBundleIdentifier"
        static let HardCodedMainBundleIdentifier = "com.pinkchicken.EasyMusic"
    }
    
    struct Image {
        static let Placeholder = "ImagePlaceholder"
        static let PlayButton = "PlayButton"
        static let PauseButton = "PauseButton"
    }
    
    struct String {
        static let MainBundleIdentifier = "com.pinkchicken.EasyMusic"
    }
    
    struct Path {
        static let DummyAudio = "/Users/larromba/Documents/Business/Pink Chicken/personal/EasyMusic/TestTunes/Bounce.mp3"
    }
    
    struct Storyboard {
         static let Player = "Player"
    }
}