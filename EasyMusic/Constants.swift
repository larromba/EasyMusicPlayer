//
//  Constants.swift
//  EasyMusic
//
//  Created by Lee Arromba on 15/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

struct Constant {
    struct Bundle {
        static let BundleDisplayName = "CFBundleName"
        static let BundleIdentifier = "CFBundleIdentifier"
        static let BundleVersion = "CFBundleShortVersionString"
        static let HardCodedMainBundleIdentifier = "com.pinkchicken.easymusicplayer"
    }
    
    struct Image {
        static let Placeholder = "ImagePlaceholder"
        static let PlayButton = "PlayButton"
        static let PauseButton = "PauseButton"
        static let RepeatButton = "RepeatButton"
        static let RepeatOneButton = "RepeatOneButton"
        static let RepeatAllButton = "RepeatAllButton"
    }
    
    struct Path {
        /*
         check this path if you get test errors:

         fatal error: 'try!' expression unexpectedly raised an error: Error Domain=NSOSStatusErrorDomain Code=2003334207 "(null)": file /Library/Caches/com.apple.xbs/Sources/swiftlang/swiftlang-802.0.53/src/swift/stdlib/public/core/ErrorType.swift, line 182
         */
        static let DummyAudio = "/Users/larromba/Documents/Business/Pink Chicken/[apps]/EasyMusicPlayer/[TestTunes]/Bounce.mp3"
    }
    
    struct Storyboard {
         static let Player = "Player"
    }
    
    struct Url {
        static let AppStoreLink = "https://itunes.apple.com/app/id1067558718"
    }
    
    struct String {
        static let AppName = "Easy Music Player"
    }
}
