//
//  MusicPlayer.swift
//  EasyMusic
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation
import MediaPlayer
import AVFoundation

enum MusicPlayerState {
    case Playing
    case Paused
    case Stopped
    case Finished
    case Error
    case Unknown
}

protocol MusicPlayerDelegate {
    func changedState(sender: MusicPlayer, state: MusicPlayerState)
    func changedPlaybackTime(sender: MusicPlayer, playbackTime: NSTimeInterval)
}

class MusicPlayer: NSObject {
    private var tracks: [MPMediaItem]! = []
    private var trackIndex: Int! = 0
    private var player: AVAudioPlayer?
    private var playbackCheckTimer: NSTimer?
    
    private(set) var delegate: MusicPlayerDelegate?
    var isPlaying: Bool! {
        guard player != nil else {
            return false
        }
        
        return player!.playing
    }
    
    init(delegate: MusicPlayerDelegate) {
        super.init()
        
        self.delegate = delegate
        
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
        commandCenter.pauseCommand.addTarget(self, action: safeSelector("pause"))
        commandCenter.playCommand.addTarget(self, action: safeSelector("play"))
        commandCenter.previousTrackCommand.addTarget(self, action: safeSelector("previous"))
        commandCenter.nextTrackCommand.addTarget(self, action: safeSelector("next"))
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: safeSelector(Constant.Notification.ApplicationWillTerminate),
            name: UIApplicationWillTerminateNotification,
            object: nil)
        
        enableAudioSession(true)
        shuffle()
    }
    
    deinit {
        enableAudioSession(false)
        
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.playCommand.removeTarget(self)
        commandCenter.previousTrackCommand.removeTarget(self)
        commandCenter.nextTrackCommand.removeTarget(self)
        
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationWillTerminateNotification,
            object: nil)
    }
    
    // MARK: - private
    
    private func enableAudioSession(enable: Bool) {
        if enable {
            _ = try! AVAudioSession.sharedInstance().setCategory(
                AVAudioSessionCategoryPlayback,
                withOptions: [])
        }
        _ = try! AVAudioSession.sharedInstance().setActive(enable)
    }
    
    private func setRemoteTrackInfo(track: TrackInfo) {        
        let songInfo: [String: AnyObject] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(image: track.artwork),
            MPNowPlayingInfoPropertyPlaybackRate: Float(1.0)
        ]

        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
    }
    
    private func startPlaybackCheckTimer() {
        playbackCheckTimer = NSTimer.scheduledTimerWithTimeInterval(1.0,
            target: self,
            selector: safeSelector("playbackCheckTimerCallback"),
            userInfo: nil,
            repeats: true)
    }
    
    private func stopPlaybackCheckTimer() {
        playbackCheckTimer?.invalidate()
        playbackCheckTimer = nil
    }
    
    private func tracksQuery() -> MPMediaQuery! {
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            let query = MPMediaQuery.mockSongsQuery()
        #else
            let query = MPMediaQuery.songsQuery()
        #endif
        
        return query
    }
    
    // MARK: - notifications
    
    func applicationWillTerminate() {
        enableAudioSession(false)
    }
    
    func playbackCheckTimerCallback() {
        delegate?.changedPlaybackTime(self, playbackTime: player!.currentTime)
    }
    
    // MARK: - internal
    
    func play() {
        guard tracks.count > 0 else {
            return
        }
        
        let track = tracks[trackIndex]
        let url = track.valueForProperty(MPMediaItemPropertyAssetURL) as? NSURL
        if url == nil {
            delegate?.changedState(self, state: MusicPlayerState.Error)
            return
        }
        
        if player == nil || player!.url!.absoluteString != url!.absoluteString {
            _ = try! player = AVAudioPlayer(contentsOfURL: url!)
            if player == nil {
                delegate?.changedState(self, state: MusicPlayerState.Error)
                return
            }
        }
        
        player!.delegate = self
        player!.prepareToPlay()
        player!.play()
        
        startPlaybackCheckTimer()
        setRemoteTrackInfo(trackInfo())
        
        delegate?.changedState(self, state: MusicPlayerState.Playing)
    }
    
    func stop() {
        player!.stop()
        player!.currentTime = 0.0
      
        stopPlaybackCheckTimer()
        
        delegate?.changedState(self, state: MusicPlayerState.Stopped)
        delegate?.changedPlaybackTime(self, playbackTime: 0.0)
    }
    
    func pause() {
        player!.pause()
     
        stopPlaybackCheckTimer()
        
        delegate?.changedState(self, state: MusicPlayerState.Paused)
    }
    
    func previous() {
        stop()
        
        var newIndex = trackIndex - 1
        if newIndex < 0 {
            newIndex = 0
            player!.currentTime = 0.0
        }
        
        trackIndex = newIndex
       
        play()
    }
    
    func next() {
        let newIndex = trackIndex + 1
        if newIndex >= tracks.count {
            stop()
            return
        }
        
        stop()
        trackIndex = trackIndex + 1
        play()
    }
    
    /** 
     @return true if suffle completes successfully
     */
    func shuffle() -> Bool {
        let query = tracksQuery()
        if query.items == nil || query.items!.count == 0 {
            // if we have no songs, bail
            return false
        }
        
        let mItems = NSMutableArray(array: query.items!)
        
        for var i = 0; i < mItems.count - 1; ++i {
            let remainingCount = mItems.count - i;
            let exchangeIndex = i + Int(arc4random_uniform(UInt32(remainingCount)))
            mItems.exchangeObjectAtIndex(i, withObjectAtIndex: exchangeIndex)
        }
        
        tracks = mItems as AnyObject as? [MPMediaItem]
        trackIndex = 0
        
        return true
    }
    
    func hasTracks() -> Bool! {
        return tracks.count > 0
    }
    
    func trackInfo() -> TrackInfo! {
        let track = tracks[trackIndex]
        
        var artwork: UIImage?
        if track.artwork != nil {
            artwork = track.artwork!.imageWithSize(CGSizeMake(30, 30));
        }
        
        let trackInfo = TrackInfo(
            artist: track.artist,
            title: track.title,
            duration: track.playbackDuration,
            artwork: artwork)
        return trackInfo
    }
    
    func tracksInfo() -> TracksInfo {
        return TracksInfo(
            trackInfo: trackInfo(),
            trackIndex: trackIndex,
            totalTracks: tracks!.count)
    }
    
    func skipTo(time: NSTimeInterval) {
        player!.currentTime = time
    }
}

// MARK: - AVAudioPlayerDelegate
extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.changedState(self, state: MusicPlayerState.Finished)
    }
}

// MARK: - Testing
extension MusicPlayer {
    func _injectPlayer(player: AVAudioPlayer) {
        self.player = player
    }
}