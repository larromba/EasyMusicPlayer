//
//  Track.swift
//  EasyMusic
//
//  Created by Lee Arromba on 03/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit
import MediaPlayer

struct Track {
    private var mediaItemArtwork: MPMediaItemArtwork?
    private(set) var artist: String!
    private(set) var title: String!
    private(set) var duration: TimeInterval = 0
    private(set) var url: URL?
    var artwork: UIImage? {
        return mediaItemArtwork?.image(at: CGSize(width: 512, height: 512))
    }
    
    init(mediaItem: MPMediaItem) {
        var artist = mediaItem.artist
        if artist == nil || artist!.characters.count == 0 {
            artist = localized("unknown artist", classId: Track.self)
        }
        
        var title = mediaItem.title
        if title == nil || title!.characters.count == 0 {
            title = localized("unknown track", classId: Track.self)
        }
        
        self.artist = artist
        self.title = title
        self.duration = mediaItem.playbackDuration
        self.mediaItemArtwork = mediaItem.artwork
        self.url = mediaItem.assetURL
    }
}

// MARK: - Equatable

extension Track: Equatable {
    static func ==(lhs: Track, rhs: Track) -> Bool {
        return (
            lhs.artist == rhs.artist &&
            lhs.title == rhs.title &&
            lhs.url == rhs.url
        )
    }
}
