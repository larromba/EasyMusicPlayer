//
//  TrackInfo.swift
//  EasyMusic
//
//  Created by Lee Arromba on 03/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

class TrackInfo: NSObject {
    private(set) var artist: String?
    private(set) var title: String?
    private(set) var duration: NSTimeInterval?
    private(set) var artwork: UIImage?
    
    init(var artist: String?, var title: String?, duration: NSTimeInterval, var artwork: UIImage?) {
        super.init()
        
        if artist == nil || artist!.characters.count == 0 {
            artist = localized("unknown artist")
        }

        if title == nil || title!.characters.count == 0 {
            title = localized("unknown track")
        }
        
        if artwork == nil {
            artwork = UIImage.safeImage(named: Constants.ImageNames.Placeholder)
        }
        
        self.artist = artist
        self.title = title
        self.duration = duration
        self.artwork = artwork
    }
}