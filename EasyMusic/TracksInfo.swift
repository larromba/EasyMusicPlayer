//
//  TracksInfo.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

class TracksInfo: NSObject {
    var trackInfo: TrackInfo!
    var trackIndex: Int!
    var totalTracks: Int!
    
    init(trackInfo: TrackInfo, trackIndex: Int, totalTracks: Int) {
        super.init()
        
        self.trackInfo = trackInfo
        self.trackIndex = trackIndex
        self.totalTracks = totalTracks
    }
}