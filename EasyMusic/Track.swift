//
//  Track.swift
//  EasyMusic
//
//  Created by Lee Arromba on 03/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit
import MediaPlayer

class Track: NSObject {
    private var mediaItemArtwork: MPMediaItemArtwork?

    private(set) var artist: String!
    private(set) var title: String!
    private(set) var duration: NSTimeInterval = 0
    private(set) var url: NSURL!
    var artwork: UIImage? {
        return mediaItemArtwork?.imageWithSize(CGSizeMake(512, 512))
    }
    
    init(var artist: String?, var title: String?, duration: NSTimeInterval, mediaItemArtwork: MPMediaItemArtwork?, url: NSURL) {
        super.init()
        
        if artist == nil || artist!.characters.count == 0 {
            artist = localized("unknown artist")
        }

        if title == nil || title!.characters.count == 0 {
            title = localized("unknown track")
        }
        
        self.artist = artist
        self.title = title
        self.duration = duration
        self.mediaItemArtwork = mediaItemArtwork
        self.url = url
    }
}