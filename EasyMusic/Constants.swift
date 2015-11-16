//
//  Constants.swift
//  EasyMusic
//
//  Created by Lee Arromba on 15/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

struct Constants {
    struct Notifications {
        static let ApplicationDidBecomeActive = "applicationDidBecomeActive"
        static let ApplicationWillTerminate = "applicationWillTerminate"
    }
    
    struct BundleKeys {
        static let BundleDisplayName = "CFBundleDisplayName"
        static let BundleIdentifier = "CFBundleIdentifier"
    }
    
    struct ImageNames {
        static let Placeholder = "ImagePlaceholder"
        static let PlayButton = "PlayButton"
        static let PauseButton = "PauseButton"
    }
    
    struct Strings {
        static let MainBundleIdentifier = "com.pinkchicken.EasyMusic"
    }
    
    struct Paths {
        static let DummyAudio = "/Users/larromba/Documents/Business/Pink Chicken/personal/EasyMusic/TestTunes/Bounce.mp3"
    }
    
    struct Environment {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
        static let Simulator = true
        #else
        static let Simulator = false
        #endif
    }
}