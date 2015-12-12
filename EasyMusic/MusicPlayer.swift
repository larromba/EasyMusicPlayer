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

protocol MusicPlayerDelegate {
    func threwError(sender: MusicPlayer, error: MusicPlayer.Error)
    func changedState(sender: MusicPlayer, state: MusicPlayer.State)
    func changedPlaybackTime(sender: MusicPlayer, playbackTime: NSTimeInterval)
}

class MusicPlayer: NSObject {
    private var player: AVAudioPlayer?
    private var playbackCheckTimer: NSTimer?
    private var playingInBackground: Bool = false
    private var trackManager: TrackManager = TrackManager()

    var delegate: MusicPlayerDelegate?
    var repeatMode: RepeatMode = RepeatMode.None
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
                delegate?.changedPlaybackTime(self, playbackTime: time)
            }
        }
        get {
            if let player = player {
                return player.currentTime
            }
            return 0.0
        }
    }
    
    enum State {
        case Playing
        case Paused
        case Stopped
        case Finished
    }
    
    enum Error {
        case Decode
        case PlayerInit
        case NoMusic
        case AVError
    }
    
    enum RepeatMode: Int {
        case None
        case One
        case All
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
    
    // MARK: - Private
    
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
    
    private func threwError(error: Error) {
        delegate?.threwError(self, error: error)
        delegate?.changedState(self, state: MusicPlayer.State.Stopped)
    }
    
    // MARK: - Notifications
    
    func applicationWillTerminate() {
        enableAudioSession(false)
    }
    
    func applicationWillResignActive() {
        if isPlaying == true {
            playingInBackground = true
        }
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
        
        delegate?.changedPlaybackTime(self, playbackTime: player!.currentTime)
    }
    
    // MARK: - Internal
    
    func enableAudioSession(enable: Bool) {
        if enable {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, withOptions: [])
            } catch _ {
                threwError(Error.AVError)
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(enable)
        } catch _ {
            threwError(Error.AVError)
        }
    }
    
    func play() {
        guard numOfTracks > 0 else {
            threwError(Error.NoMusic)
            return
        }
        
        if player == nil || player!.url!.absoluteString != currentTrack.url.absoluteString {
            do {
                try player = AVAudioPlayer(contentsOfURL: currentTrack.url)
            } catch _ {
                threwError(Error.PlayerInit)
                return
            }
            player!.delegate = self
        }
        
        var success = player!.prepareToPlay()
        guard success == true else {
            threwError(Error.AVError)
            return
        }
        
        success = player!.play()
        guard success == true else {
            threwError(Error.AVError)
            return
        }
        
        startPlaybackCheckTimer()
        
        delegate?.changedState(self, state: State.Playing)
    }
    
    func stop() {
        guard player != nil else {
            return
        }
        
        player!.stop()
        
        stopPlaybackCheckTimer()
        time = 0.0
        
        delegate?.changedState(self, state: State.Stopped)
    }
    
    func pause() {
        guard player != nil else {
            return
        }
        
        player!.pause()
     
        stopPlaybackCheckTimer()
        
        delegate?.changedState(self, state: State.Paused)
    }
    
    func previous() {
        stop()
        
        let result = trackManager.cuePrevious()
        if repeatMode == RepeatMode.All && result == false {
            trackManager.cueEnd()
        }
       
        play()
    }
    
    func next() {
        stop()
        
        let result = trackManager.cueNext()
        if repeatMode == RepeatMode.All && result == false {
            trackManager.cueStart()
        } else if result == false {
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
        if flag == false {
            threwError(Error.AVError)
            return
        }
        
        switch repeatMode {
        case .None:
            let result = trackManager.cueNext()
            if result == false {
                trackManager.cueStart()
                delegate?.changedState(self, state: State.Finished)
                return
            }
            play()
            break
        case .One:
            play()
            break
        case .All:
            let result = trackManager.cueNext()
            if result == false {
                trackManager.cueStart()
            }
            play()
            break
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        if let error = error {
            Analytics.shared.sendErrorEvent(error, classId: self.className())
        }
        
        threwError(Error.Decode)
    }
}

// MARK: - Testing

extension MusicPlayer {
    var __player: AVAudioPlayer? {
        get { return player }
        set { player = newValue }
    }
    var __trackManager: TrackManager {
        get { return trackManager }
        set { trackManager = newValue }
    }
    var __playbackCheckTimer: NSTimer? {
        get { return playbackCheckTimer }
        set { playbackCheckTimer = newValue }
    }
}