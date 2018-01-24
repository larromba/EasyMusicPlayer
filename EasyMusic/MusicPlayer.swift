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
    private var player: AVAudioPlayer?
    private var playbackCheckTimer: Timer?
    private var seekTimer: Timer?
    private var isHeadphonesRemovedByMistake: Bool = false
    private var isPlayingInBackground: Bool = false
    private var isAudioSessionInterrupted: Bool = false
    private var seekStartDate: Date?

    weak var delegate: MusicPlayerDelegate?
    var trackManager: TrackManager = TrackManager()
    var repeatMode: RepeatMode = RepeatMode.none
    var isPlaying: Bool {
        if let player = player {
            return player.isPlaying
        }
        return false
    }
    var time: TimeInterval {
        set {
            if let player = player {
                player.currentTime = newValue
            }
            delegate?.changedPlaybackTime(self, playbackTime: time)
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
        case authorization
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
        commandCenter.togglePlayPauseCommand.addTarget(self, action: #selector(togglePlayPause))
        commandCenter.pauseCommand.addTarget(self, action: #selector(pause))
        commandCenter.playCommand.addTarget(self, action: #selector(play))
        commandCenter.previousTrackCommand.addTarget(self, action: #selector(previous))
        commandCenter.nextTrackCommand.addTarget(self, action: #selector(next))
        commandCenter.seekForwardCommand.addTarget(self, action: #selector(seekForward(_:)))
        commandCenter.seekBackwardCommand.addTarget(self, action: #selector(seekBackward(_:)))
        commandCenter.changePlaybackPositionCommand.addTarget(self, action: #selector(changePlaybackPosition(_:)))
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationWillTerminate(_:)),
            name: NSNotification.Name.UIApplicationWillTerminate,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationWillResignActive(_:)),
            name: NSNotification.Name.UIApplicationWillResignActive,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(applicationDidBecomeActive(_:)),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(audioSessionRouteChange(_:)),
            name: NSNotification.Name.AVAudioSessionRouteChange,
            object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(audioSessionInterruption(_:)),
            name: NSNotification.Name.AVAudioSessionInterruption,
            object: nil)
        
        authorizeThenPerform({
            self.trackManager.loadTracks()
            if self.trackManager.numOfTracks == 0 {
                self.trackManager.shuffleTracks()
            }
        })
    }
    
    deinit {
        _ = enableAudioSession(false)
        
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
    
    private func startPlaybackCheckTimer() {
        if playbackCheckTimer != nil {
            stopPlaybackCheckTimer()
        }
        
        playbackCheckTimer = Timer.scheduledTimer(timeInterval: 1.0,
            target: self,
            selector: #selector(playbackCheckTimerCallback),
            userInfo: nil,
            repeats: true)
    }
    
    private func stopPlaybackCheckTimer() {
        playbackCheckTimer?.invalidate()
        playbackCheckTimer = nil
    }
    
    private func startSeekTimerWithAction(_ action: Selector) {
        if seekTimer != nil {
            stopSeekTimer()
        }
        
        seekTimer = Timer.scheduledTimer(timeInterval: 0.2,
            target: self,
            selector: action,
            userInfo: nil,
            repeats: true)
    }
    
    private func stopSeekTimer() {
        seekTimer?.invalidate()
        seekTimer = nil
    }
    
    private func throwError(_ error: MusicError) {
        stop()
        delegate?.threwError(self, error: error)
    }
    
    private func authorizeThenPerform(_ block: @escaping (() -> Void)) {
        guard trackManager.authorized else {
            trackManager.authorize({ (_ success: Bool) in
                guard success else {
                    self.throwError(.authorization)
                    return
                }
                block()
            })
            return
        }
        block()
    }
    
    // MARK: - Notifications
    
    @objc private func applicationWillTerminate(_ notifcation: Notification) {
        _ = enableAudioSession(false)
    }
    
    @objc private func applicationWillResignActive(_ notifcation: Notification) {
        if isPlaying {
            isPlayingInBackground = true
        }
    }
    
    @objc private func applicationDidBecomeActive(_ notifcation: Notification) {
        isPlayingInBackground = false
    }
    
    @objc private func audioSessionRouteChange(_ notifcation: Notification) {
        guard
            let rawValue = (notifcation.userInfo?[AVAudioSessionRouteChangeReasonKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSessionRouteChangeReason(rawValue: rawValue) else {
            return
        }
        switch reason {
        case .oldDeviceUnavailable:
            if isPlaying {
                isHeadphonesRemovedByMistake = true
                pause()
            }
        case .newDeviceAvailable:
            if !isPlaying && isHeadphonesRemovedByMistake {
                isHeadphonesRemovedByMistake = false
                play()
            }
        default:
            break
        }
    }
    
    @objc private func audioSessionInterruption(_ notification: Notification) {
        guard
            let rawValue = (notification.userInfo?[AVAudioSessionInterruptionTypeKey] as? NSNumber)?.uintValue,
            let reason = AVAudioSessionInterruptionType(rawValue: rawValue) else {
                return
        }
        switch reason {
        case .began:
            if isPlayingInBackground || isPlaying {
                isAudioSessionInterrupted = true
                pause()
            }
        case .ended:
            if !isPlaying && isAudioSessionInterrupted {
                isAudioSessionInterrupted = false
                play()
            }
        }
    }

    // MARK: - Timer
    
    @objc private func playbackCheckTimerCallback() {
        guard let player = player else {
            return
        }
        delegate?.changedPlaybackTime(self, playbackTime: player.currentTime)
    }

    @objc private func seekForwardTimerCallback() {
        guard let player = player, seekTimer != nil else {
            return
        }
        player.currentTime += 1.0
    }
    
    @objc private func seekBackwardTimerCallback() {
        guard let player = player, seekTimer != nil else {
            return
        }
        player.currentTime -= 1.0
    }
    
    // MARK: - Internal
    
    func enableAudioSession(_ enable: Bool) -> Bool {
        if enable {
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, with: [])
            } catch {
                log(error.localizedDescription)
                return false
            }
        }
        
        do {
            try AVAudioSession.sharedInstance().setActive(enable)
        } catch {
            log(error.localizedDescription)
            return false
        }
        
        return true
    }
    
    @objc func play() {
        authorizeThenPerform({
            guard self.trackManager.numOfTracks > 0 else {
                self.throwError(.noMusic)
                return
            }
            guard self.volume > 0.0 else {
                self.throwError(.noVolume)
                return
            }
            guard let assetUrl = self.trackManager.currentTrack.assetURL else {
                self.throwError(.playerInit)
                return
            }
            
            if self.player == nil || self.player?.url?.absoluteString != assetUrl.absoluteString {
                do {
                    let player = try AVAudioPlayer(contentsOf: assetUrl)
                    player.delegate = self
                    self.player = player
                } catch _ {
                    self.throwError(.playerInit)
                    return
                }
            }
            
            let enable = self.enableAudioSession(true)
            let prepare = self.player?.prepareToPlay() ?? false
            let play = self.player?.play() ?? false
            
            guard enable, prepare, play else {
                log("enable: \(enable), prepare: \(prepare), play: \(play)")
                self.throwError(.avError)
                return
            }

            self.startPlaybackCheckTimer()
            self.isHeadphonesRemovedByMistake = false
            self.isAudioSessionInterrupted = false
            self.delegate?.changedState(self, state: .playing)
        })
    }
    
    func stop() {
        guard let player = player else {
            return
        }
        
        player.stop()
        self.player = nil
        
        stopPlaybackCheckTimer()
        time = 0.0
        
        delegate?.changedState(self, state: .stopped)
    }
    
    @objc func pause() {
        guard let player = player else {
            return
        }
        
        player.pause()
     
        stopPlaybackCheckTimer()
        
        delegate?.changedState(self, state: .paused)
    }
    
    @objc func togglePlayPause() {
        if isPlaying {
            pause()
        } else {
            play()
        }
    }
    
    @objc func previous() {
        stop()
        
        let result = trackManager.cuePrevious()
        if repeatMode == .all && !result {
            trackManager.cueEnd()
        }
       
        play()
    }
    
    @objc func next() {
        stop()
        
        let result = trackManager.cueNext()
        if repeatMode == .all && !result {
            trackManager.cueStart()
        } else if !result {
            return
        }

        play()
    }
    
    @objc func seekForward(_ event: MPSeekCommandEvent) {
        guard player != nil else {
            return
        }
        
        switch event.type {
        case .beginSeeking:
            seekForwardStart()
        case .endSeeking:
            seekForwardEnd()
        }
    }
    
    @objc func seekBackward(_ event: MPSeekCommandEvent) {
        guard player != nil else {
            return
        }
        
        switch event.type {
        case .beginSeeking:
            seekBackwardStart()
        case .endSeeking:
            seekBackwardEnd()
        }
    }
    
    @objc func changePlaybackPosition(_ event: MPChangePlaybackPositionCommandEvent) {
        time = event.positionTime
    }
    
    func seekForwardStart() {
        seekStartDate = Date()
        startSeekTimerWithAction(#selector(seekForwardTimerCallback))
    }
    
    func seekForwardEnd() {
        stopSeekTimer()
        
        if let seekStartDate = seekStartDate {
            Analytics.shared.sendTimedAppEvent("seek_forward", fromDate: seekStartDate, toDate: Date())
        }
    }
    
    func seekBackwardStart() {
        seekStartDate = Date()
        startSeekTimerWithAction(#selector(seekBackwardTimerCallback))
    }
    
    func seekBackwardEnd() {
        stopSeekTimer()
        
        if let seekStartDate = seekStartDate {
            Analytics.shared.sendTimedAppEvent("seek_backward", fromDate: seekStartDate, toDate: Date())
        }
    }
    
    func shuffle() {
        authorizeThenPerform({
            self.trackManager.shuffleTracks()
        })
    }
}

// MARK: - AVAudioPlayerDelegate

extension MusicPlayer: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        stopPlaybackCheckTimer()
        stopSeekTimer()
        time = 0.0
        
        if !flag {
            throwError(.avError)
            return
        }
        
        switch repeatMode {
        case .none:
            let result = trackManager.cueNext()
            if !result {
                trackManager.cueStart()
                delegate?.changedState(self, state: .finished)
                return
            }
            play()
        case .one:
            play()
        case .all:
            let result = trackManager.cueNext()
            if !result {
                trackManager.cueStart()
            }
            play()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            Analytics.shared.sendErrorEvent(error, classId: classForCoder)
        }
        
        throwError(.decode)
    }
}

// MARK: - Testing

extension MusicPlayer {
    var __player: AVAudioPlayer? {
        get { return player }
        set { player = newValue }
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
