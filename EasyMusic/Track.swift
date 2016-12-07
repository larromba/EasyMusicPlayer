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
    fileprivate var mediaItemArtwork: MPMediaItemArtwork?
    fileprivate(set) var artist: String!
    fileprivate(set) var title: String!
    fileprivate(set) var duration: TimeInterval = 0
    fileprivate(set) var url: URL?
    var artwork: UIImage? {
        return mediaItemArtwork?.image(at: CGSize(width: 512, height: 512))
    }
    
    init(mediaItem: MPMediaItem) {
        super.init()
        
        var artist = mediaItem.artist
        if artist == nil || artist!.characters.count == 0 {
            artist = localized("unknown artist")
        }
        
        var title = mediaItem.title
        if title == nil || title!.characters.count == 0 {
            title = localized("unknown track")
        }
        
        self.artist = artist
        self.title = title
        self.duration = mediaItem.playbackDuration
        self.mediaItemArtwork = mediaItem.artwork
        self.url = mediaItem.assetURL
    }
}
