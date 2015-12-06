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
    private var playingInBackground: Bool = false
    private var trackManager: TrackManager = TrackManager()
    
    var delegate: MusicPlayerDelegate?
    var isPlaying: Bool {
        if let player = player {
            return player.playing
        }
        return false
    }
    var currentTrack: Track {
        return trackManager.currentTrack
    }
    var currentTrackNumber: Int {
        return trackManager.currentTrackNumber
    }
    var numOfTracks: Int {
        return trackManager.numOfTracks
    }
    var time: NSTimeInterval {
        set {
            if let player = player {
                player.currentTime = newValue
                changedPlaybackTime(time)
            }
        }
        get {
            if let player = player {
                return player.currentTime
            }
            return 0.0
        }
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
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: safeSelector(Constant.Notification.ApplicationWillResignActive),
            name: UIApplicationWillResignActiveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: safeSelector(Constant.Notification.ApplicationDidBecomeActive),
            name: UIApplicationDidBecomeActiveNotification,
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
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationWillResignActiveNotification,
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
    
    private func threwError(error: MusicPlayerError) {
        delegate?.threwError(self, error: error)
        changedState(MusicPlayerState.Stopped)
    }
    
    private func changedState(state: MusicPlayerState) {
        delegate?.changedState(self, state: state)
    }
    
    private func changedPlaybackTime(playbackTime: NSTimeInterval) {
        delegate?.changedPlaybackTime(self, playbackTime: playbackTime)
    }
    
    // MARK: - notifications
    
    func applicationWillTerminate() {
        enableAudioSession(false)
    }
    
    func applicationWillResignActive() {
        playingInBackground = true
    }
    
    func applicationDidBecomeActive() {
        if playingInBackground == true && isPlaying == false {
            stop()
        }
        playingInBackground = false
    }
    
    func playbackCheckTimerCallback() {
        guard player != nil else {
            return
        }
        
        changedPlaybackTime(player!.currentTime)
    }
    
    // MARK: - internal
    
    func enableAudioSession(enable: Bool) {
        if enable {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
            } catch _ {
                threwError(MusicPlayerError.AVError)
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(enable)
        } catch _ {
            threwError(MusicPlayerError.AVError)
        }
    }
    
    func play() {
        guard numOfTracks > 0 else {
            threwError(MusicPlayerError.NoMusic)
            return
        }
        
        if player == nil || player!.url!.absoluteString != currentTrack.url.absoluteString {
            do {
                try player = AVAudioPlayer(contentsOfURL: currentTrack.url)
            } catch _ {
                threwError(MusicPlayerError.PlayerInit)
                return
            }
            player!.delegate = self
        }
        
        var success = player!.prepareToPlay()
        guard success == true else {
            threwError(MusicPlayerError.AVError)
            return
        }
        
        success = player!.play()
        guard success == true else {
            threwError(MusicPlayerError.AVError)
            return
        }
        
        startPlaybackCheckTimer()
        
        changedState(MusicPlayerState.Playing)
    }
    
    func stop() {
        guard player != nil else {
            return
        }
        
        player!.stop()
        
        stopPlaybackCheckTimer()
        time = 0.0
        
        changedState(MusicPlayerState.Stopped)
    }
    
    func pause() {
        guard player != nil else {
            return
        }
        
        player!.pause()
     
        stopPlaybackCheckTimer()
        
        changedState(MusicPlayerState.Paused)
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
}

// MARK: - AVAudioPlayerDelegate
extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        if flag == true {
            changedState(MusicPlayerState.Finished)
        } else {
            threwError(MusicPlayerError.AVError)
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        threwError(MusicPlayerError.Decode)
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
    
    func _injectPlaybackCheckTimer(playbackCheckTimer: NSTimer) {
        self.playbackCheckTimer = playbackCheckTimer
    }
}