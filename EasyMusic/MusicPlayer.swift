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
}

enum MusicPlayerError {
    case InvalidUrl
    case Decode
    case PlayerInit
    case NoMusic
    case AVError
}

protocol MusicPlayerDelegate {
    func threwError(sender: MusicPlayer, error: MusicPlayerError)
    func changedState(sender: MusicPlayer, state: MusicPlayerState)
    func changedPlaybackTime(sender: MusicPlayer, playbackTime: NSTimeInterval)
}

class MusicPlayer: NSObject {
    private var player: AVAudioPlayer?
    private var playbackCheckTimer: NSTimer?
    
    private(set) var trackManager: TrackManager! = TrackManager()
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
    
    func enableAudioSession(enable: Bool) {
        if enable {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
            }
            catch _ {
                delegate?.threwError(self, error: MusicPlayerError.AVError)
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(enable)
        }
        catch _ {
            delegate?.threwError(self, error: MusicPlayerError.AVError)
        }
    }
    
    func play() {
        guard trackManager.numOfTracks() > 0 else {
            delegate?.threwError(self, error: MusicPlayerError.NoMusic)
            return
        }
        
        let track = trackManager.currentTrack()
        if track.url.absoluteString.characters.count == 0 {
            delegate?.threwError(self, error: MusicPlayerError.InvalidUrl)
            return
        }
        
        if player == nil || player!.url!.absoluteString != track.url.absoluteString {
            do {
                try player = AVAudioPlayer(contentsOfURL: track.url)
            }
            catch _ {
                delegate?.threwError(self, error: MusicPlayerError.PlayerInit)
                return
            }
            player!.delegate = self
        }
        
        var success = player!.prepareToPlay()
        guard success == true else {
            delegate?.threwError(self, error: MusicPlayerError.AVError)
            return
        }
        
        success = player!.play()
        guard success == true else {
            delegate?.threwError(self, error: MusicPlayerError.AVError)
            return
        }
        
        startPlaybackCheckTimer()
        
        delegate?.changedState(self, state: MusicPlayerState.Playing)
    }
    
    func stop() {
        player!.stop()
        
        stopPlaybackCheckTimer()
        skipTo(0.0)
        
        delegate?.changedState(self, state: MusicPlayerState.Stopped)
    }
    
    func pause() {
        player!.pause()
     
        stopPlaybackCheckTimer()
        
        delegate?.changedState(self, state: MusicPlayerState.Paused)
    }
    
    func previous() {
        stop()
        
        _ = trackManager.cuePrevious()
       
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
    
    func currentTrack() -> Track! {
        return trackManager.currentTrack()
    }
    
    func currentTrackNumber() -> Int! {
        return trackManager.currentTrackNumber()
    }
    
    func skipTo(time: NSTimeInterval) {
        player!.currentTime = time
        delegate?.changedPlaybackTime(self, playbackTime: time)
    }
    
    func numOfTracks() -> Int! {
        return trackManager.numOfTracks()
    }
}

// MARK: - AVAudioPlayerDelegate
extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.changedState(self, state: MusicPlayerState.Finished)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        delegate?.threwError(self, error: MusicPlayerError.Decode)
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