//
//  MusicPlayerTests.swift
//  EasyMusicTests
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import AVFoundation
@testable import EasyMusic

class MusicPlayerTests: XCTestCase {
    var musicPlayer: EasyMusic.MusicPlayer!
    
    override func setUp() {
        super.setUp()
        musicPlayer = MusicPlayer(delegate: self)
    }
    
   
}

// MARK: - ScrobbleViewDelegate
extension MusicPlayerTests: MusicPlayerDelegate {
    func threwError(sender: EasyMusic.MusicPlayer, error: MusicPlayerError) {}
    func changedState(sender: EasyMusic.MusicPlayer, state: MusicPlayerState) {}
    func changedPlaybackTime(sender: EasyMusic.MusicPlayer, playbackTime: NSTimeInterval) {}
}