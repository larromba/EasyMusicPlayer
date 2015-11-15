//
//  Simulator.swift
//  EasyMusic
//
//  Created by Lee Arromba on 15/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import MediaPlayer

extension MPMediaQuery {
    public class func mockSongsQuery() -> MPMediaQuery {
        let item1 = MockMediaItem()
        item1.title = "Title 1"
        item1.artist = "Artist 1"
        item1.playbackDuration = 219
        
        let item2 = MockMediaItem()
        item2.title = "Title 2"
        item2.artist = "Artist 2"
        item2.playbackDuration = 219
        
        let item3 = MockMediaItem()
        item3.title = "Title 3"
        item3.artist = "Artist 3"
        item3.playbackDuration = 219
        
        let query = MockMediaQuery()
        query.items = [item1,item2,item3]
        
        return query
    }
}

class MockMediaItem: MPMediaItem {
    var _title: String?
    override var title: String {
        get {
            return _title!
        }
        set {
            _title = newValue
        }
    }
    
    var _artist: String?
    override var artist: String {
        get {
            return _artist!
        }
        set {
            _artist = newValue
        }
    }
    
    var _playbackDuration: NSTimeInterval?
    override var playbackDuration: NSTimeInterval {
        get {
            return _playbackDuration!
        }
        set {
            _playbackDuration = newValue
        }
    }
    
    override func valueForProperty(property: String) -> AnyObject? {
        if property == MPMediaItemPropertyAssetURL {
            return NSURL(fileURLWithPath: "/Users/larromba/Documents/Business/Pink Chicken/personal/EasyMusic/TestTunes/Bounce.mp3")
        }
        
        return nil
    }
}

class MockMediaQuery: MPMediaQuery {
    var _items: [MPMediaItem]?
    override var items: [MPMediaItem]! {
        get {
            return _items
        }
        set {
            _items = newValue
        }
    }
}