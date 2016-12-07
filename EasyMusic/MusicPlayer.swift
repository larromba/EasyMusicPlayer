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

protocol MusicPlayerDelegate: class {
    func threwError(_ sender: MusicPlayer, error: MusicPlayer.MusicError)
    func changedState(_ sender: MusicPlayer, state: MusicPlayer.State)
    func changedPlaybackTime(_ sender: MusicPlayer, playbackTime: TimeInterval)
}

class MusicPlayer: NSObject {
    fileprivate var player: AVAudioPlayer?
    fileprivate var playbackCheckTimer: Timer?
    fileprivate var seekTimer: Timer?
    fileprivate var isPlayingInBackground: Bool = false
    fileprivate var isAudioSessionInterrupted: Bool = false
    fileprivate var trackManager: TrackManager = TrackManager()
    fileprivate var seekStartDate: Date?

    weak var delegate: MusicPlayerDelegate?
    var repeatMode: RepeatMode = RepeatMode.none
    var isPlaying: Bool {
        if let player = player {
            return player.isPlaying
        }
        return false
    }
    var currentResolvedTrack: Track {
        return trackManager.currentResolvedTrack
    }
    var currentTrack: MPMediaItem {
        return trackManager.currentTrack
    }
    var currentTrackNumber: Int {
        return trackManager.currentTrackNumber
    }
    var numOfTracks: Int {
        return trackManager.numOfTracks
    }
    var time: TimeInterval {
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
    var volume: Float {
        return AVAudioSession.sharedInstance().outputVolume
    }
    
    enum State {
        case playing
        case paused
        case stopped
        case finished
    }
    
    enum MusicError: Error {
        case decode
        case playerInit
        case noMusic
        case noVolume
        case avError
    }
    
    enum RepeatMode: Int {
        case none
        case one
        case all
    }
    
    init(delegate: MusicPlayerDelegate) {
        super.init()
        
        self.delegate = delegate

        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.togglePlayPauseCommand.addTarget(self, action: safeSelector("togglePlayPause"))
        commandCenter.pauseCommand.addTarget(self, action: safeSelector("pause"))
        commandCenter.playCommand.addTarget(self, action: safeSelector("play"))
        commandCenter.previousTrackCommand.addTarget(self, action: safeSelector("previous"))
        commandCenter.nextTrackCommand.addTarget(self, action: safeSelector("next"))
        commandCenter.seekForwardCommand.addTarget(self, action: safeSelector("seekForward:"))
        commandCenter.seekBackwardCommand.addTarget(self, action: safeSelector("seekBackward:"))
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: safeSelector("changePlaybackPosition:"))
        
        NotificationCenter.default.addObserver(self,
            selector: safeSelector(Constant.Notification.ApplicationWillTerminate),
            name: NSNotification.Name.UIApplicationWillTerminate,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: safeSelector(Constant.Notification.ApplicationWillResignActive),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: safeSelector(Constant.Notification.ApplicationDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: safeSelector("\(Constant.Notification.AudioSessionRouteChange):"),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: safeSelector("\(Constant.Notification.AudioSessionInterruption):"),
            name: NSNotification.Name.AVAudioSessionInterruption,
            object: nil)
        
        enableAudioSession(true)
        shuffle()
    }
    
    deinit {
        enableAudioSession(false)
        
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.togglePlayPauseCommand.removeTarget(self)
        commandCenter.pauseCommand.removeTarget(self)
        commandCenter.playCommand.removeTarget(self)
        commandCenter.previousTrackCommand.removeTarget(self)
        commandCenter.nextTrackCommand.removeTarget(self)
        commandCenter.seekForwardCommand.removeTarget(self)
        commandCenter.seekBackwardCommand.removeTarget(self)
        commandCenter.changePlaybackPositionCommand.removeTarget(self)
        
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.UIApplicationWillTerminate,
            object: nil)
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil)
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.AVAudioSessionInterruption,
            object: nil)
    }
    
    // MARK: - Private
    
    fileprivate func startPlaybackCheckTimer() {
        if playbackCheckTimer != nil {
            stopPlaybackCheckTimer()
        }
        
        playbackCheckTimer = Timer.scheduledTimer(timeInterval: 1.0,
            target: self,
            selector: safeSelector("playbackCheckTimerCallback"),
            userInfo: nil,
            repeats: true)
    }
    
    fileprivate func stopPlaybackCheckTimer() {
        playbackCheckTimer?.invalidate()
        playbackCheckTimer = nil
    }
    
    fileprivate func startSeekTimerWithAction(_ action: Selector) {
        if seekTimer != nil {
            stopSeekTimer()
        }
        
        seekTimer = Timer.scheduledTimer(timeInterval: 0.2,
            target: self,
            selector: action,
            userInfo: nil,
            repeats: true)
    }
    
    fileprivate func stopSeekTimer() {
        seekTimer?.invalidate()
        seekTimer = nil
    }
    
    fileprivate func threwError(_ error: MusicError) {
        stopSeekTimer()
        delegate?.threwError(self, error: error)
        delegate?.changedState(self, state: MusicPlayer.State.stopped)
    }
    
    // MARK: - Notifications
    
    func applicationWillTerminate() {
        enableAudioSession(false)
    }
    
    func applicationWillResignActive() {
        if isPlaying == true {
            isPlayingInBackground = true
        }
    }
    
    func applicationDidBecomeActive() {
        isPlayingInBackground = false
    }
    
    func audioSessionRouteChange(_ notifcation: Notification) {
        if let rawValue = (notifcation.userInfo?[AVAudioSessionRouteChangeReasonKey] as AnyObject).uintValue {
            if let reason = AVAudioSessionRouteChangeReason(rawValue: rawValue) {
                switch reason {
                case .newDeviceAvailable, .oldDeviceUnavailable:
                    if isPlaying == true {
                        pause()
                    }
                    break
                default:
                    break
                }
            }
        }
    }
    
    func audioSessionInterruption(_ notification: Notification) {
        if let rawValue = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as AnyObject).uintValue {
            if let reason = AVAudioSessionInterruptionType(rawValue: rawValue) {
                switch reason {
                case .began:
                    if isPlayingInBackground == true || isPlaying == true {
                        isAudioSessionInterrupted = true
                        pause()
                    }
                    break
                case .ended:
                    if isAudioSessionInterrupted == true {
                        isAudioSessionInterrupted = false
                        play()
                    }
                    break
                }
            }
        }
    }
    
    // MARK: - Timer
    
    func playbackCheckTimerCallback() {
        guard player != nil else {
            return
        }
        
        delegate?.changedPlaybackTime(self, playbackTime: player!.currentTime)
    }
    
    func seekForwardTimerCallback() {
        if seekTimer != nil {
            player!.currentTime += 1.0
        }
    }
    
    func seekBackwardTimerCallback() {
        if seekTimer != nil {
            player!.currentTime -= 1.0
        }
    }
    
    // MARK: - Internal
    
    func enableAudioSession(_ enable: Bool) {
        if enable {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
            } catch _ {
                threwError(MusicError.avError)
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(enable)
        } catch _ {
            threwError(MusicError.avError)
        }
    }
    
    func play() {
        guard numOfTracks > 0 else {
            threwError(MusicError.noMusic)
            return
        }
        
        guard volume > 0.0 else {
            threwError(MusicError.noVolume)
            return
        }
        
        let assetUrl = currentTrack.assetURL
        guard assetUrl != nil else {
            threwError(MusicError.playerInit)
            return
        }
        
        if player == nil || player!.url!.absoluteString != assetUrl!.absoluteString {
            do {
                try player = AVAudioPlayer(contentsOf: assetUrl!)
            } catch _ {
                threwError(MusicError.playerInit)
                return
            }
            player!.delegate = self
        }
        
        var success = player!.prepareToPlay()
        guard success == true else {
            threwError(MusicError.avError)
            return
        }
                
        success = player!.play()
        guard success == true else {
            threwError(MusicError.avError)
            return
        }
        
        startPlaybackCheckTimer()
        
        delegate?.changedState(self, state: State.playing)
    }
    
    func stop() {
        guard player != nil else {
            return
        }
        
        player!.stop()
        
        stopPlaybackCheckTimer()
        time = 0.0
        
        delegate?.changedState(self, state: State.stopped)
    }
    
    func pause() {
        guard player != nil else {
            return
        }
        
        player!.pause()
     
        stopPlaybackCheckTimer()
        
        delegate?.changedState(self, state: State.paused)
    }
    
    func togglePlayPause() {
        if isPlaying == false {
            play()
        } else {
            pause()
        }
    }
    
    func previous() {
        stop()
        
        let result = trackManager.cuePrevious()
        if repeatMode == RepeatMode.all && result == false {
            trackManager.cueEnd()
        }
       
        play()
    }
    
    func next() {
        stop()
        
        let result = trackManager.cueNext()
        if repeatMode == RepeatMode.all && result == false {
            trackManager.cueStart()
        } else if result == false {
            return
        }

        play()
    }
    
    func seekForward(_ event: MPSeekCommandEvent) {
        guard player != nil else {
            return
        }
        
        switch event.type {
        case .beginSeeking:
            seekForwardStart()
            break
        case .endSeeking:
            seekForwardEnd()
            break
        }
    }
    
    func seekBackward(_ event: MPSeekCommandEvent) {
        guard player != nil else {
            return
        }
        
        switch event.type {
        case .beginSeeking:
            seekBackwardStart()
            break
        case .endSeeking:
            seekBackwardEnd()
            break
        }
    }
    
    func changePlaybackPosition(_ event: MPChangePlaybackPositionCommandEvent) {
        time = event.positionTime
    }
    
    func seekForwardStart() {
        seekStartDate = Date()
        startSeekTimerWithAction(safeSelector("seekForwardTimerCallback"))
    }
    
    func seekForwardEnd() {
        stopSeekTimer()
        
        if let seekStartDate = seekStartDate {
            Analytics.shared.sendTimedAppEvent("seek_forward", fromDate: seekStartDate, toDate: Date())
        }
    }
    
    func seekBackwardStart() {
        seekStartDate = Date()
        startSeekTimerWithAction(safeSelector("seekBackwardTimerCallback"))
    }
    
    func seekBackwardEnd() {
        stopSeekTimer()
        
        if let seekStartDate = seekStartDate {
            Analytics.shared.sendTimedAppEvent("seek_backward", fromDate: seekStartDate, toDate: Date())
        }
    }

    func shuffle() {
        trackManager.shuffleTracks()
    }
}

// MARK: - AVAudioPlayerDelegate

extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaybackCheckTimer()
        stopSeekTimer()
        
        if flag == false {
            threwError(MusicError.avError)
            return
        }
        
        switch repeatMode {
        case .none:
            let result = trackManager.cueNext()
            if result == false {
                trackManager.cueStart()
                delegate?.changedState(self, state: State.finished)
                return
            }
            play()
            break
        case .one:
            play()
            break
        case .all:
            let result = trackManager.cueNext()
            if result == false {
                trackManager.cueStart()
            }
            play()
            break
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            Analytics.shared.sendErrorEvent(error, classId: self.className())
        }
        
        threwError(MusicError.decode)
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
    var __playbackCheckTimer: Timer? {
        get { return playbackCheckTimer }
        set { playbackCheckTimer = newValue }
    }
    var __isPlayingInBackground: Bool {
        get { return isPlayingInBackground }
        set { isPlayingInBackground = newValue }
    }
    var __isAudioSessionInterrupted: Bool {
        get { return isAudioSessionInterrupted }
        set { isAudioSessionInterrupted = newValue }
    }
}
