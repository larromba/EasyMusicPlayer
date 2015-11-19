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
    case NoMusic
    case Error
    case Unknown
}

protocol MusicPlayerDelegate {
    func changedState(sender: MusicPlayer, state: MusicPlayerState)
    func changedPlaybackTime(sender: MusicPlayer, playbackTime: NSTimeInterval)
}

class MusicPlayer: NSObject {
    private(set) var trackManager: TrackManager! = TrackManager()
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
    
    // MARK: - notifications
    
    func applicationWillTerminate() {
        enableAudioSession(false)
    }
    
    func playbackCheckTimerCallback() {
        delegate?.changedPlaybackTime(self, playbackTime: player!.currentTime)
    }
    
    // MARK: - internal
    
    func play() {
        guard trackManager.tracks.count > 0 else {
            delegate?.changedState(self, state: MusicPlayerState.NoMusic)
            return
        }
        
        let track = trackManager.currentTrack()
        if track.url == nil {
            delegate?.changedState(self, state: MusicPlayerState.Error)
            return
        }
        
        if player == nil || player!.url!.absoluteString != track.url!.absoluteString {
            _ = try! player = AVAudioPlayer(contentsOfURL: track.url!)
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
        
        if trackManager.cuePrevious() == false {
            player!.currentTime = 0.0
        }
       
        play()
    }
    
    func next() {
        stop()
        
        if trackManager.cueNext() == false {
            return
        }
        
        play()
    }

    func shuffle() {
        trackManager.shuffleTracks()
    }
    
    func trackInfo() -> TrackInfo! {
        return trackManager.currentTrack()
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
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        delegate?.changedState(self, state: MusicPlayerState.Error)
    }
    
    func audioPlayerBeginInterruption(player: AVAudioPlayer) {
        delegate?.changedState(self, state: MusicPlayerState.Paused)
    }
    
    func audioPlayerEndInterruption(player: AVAudioPlayer, withOptions flags: Int) {
        delegate?.changedState(self, state: MusicPlayerState.Playing)
    }
}

// MARK: - Testing
extension MusicPlayer {
    func _injectPlayer(player: AVAudioPlayer) {
        self.player = player
    }
    func _injectTrackManager(trackManager: TrackManager) {
        self.trackManager = trackManager
    }
}