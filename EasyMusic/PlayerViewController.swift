//
//  PlayerViewController.swift
//  EasyMusic
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit
import MediaPlayer

class PlayerViewController: UIViewController {
    @IBOutlet private weak var scrobbleView: ScrobbleView!
    @IBOutlet private weak var infoView: InfoView!
    @IBOutlet private weak var controlsView: ControlsView!
    
    private lazy var musicPlayer: MusicPlayer = MusicPlayer(delegate: self)
    private var shareManager: ShareManager = ShareManager()
    private var userScrobbling: Bool = false
    private var AlertController = UIAlertController.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlsView.delegate = self
        scrobbleView.delegate = self
        
        if let repeatMode = UserData.repeatMode {
            musicPlayer.repeatMode = repeatMode
            
            switch repeatMode {
            case .None:
                controlsView.repeatButtonState = RepeatButton.State.None
                break
            case .One:
                controlsView.repeatButtonState = RepeatButton.State.One
                break
            case .All:
                controlsView.repeatButtonState = RepeatButton.State.All
                break
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: safeSelector(Constant.Notification.ApplicationDidBecomeActive),
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self,
            name: UIApplicationDidBecomeActiveNotification,
            object: nil)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        Analytics.shared.sendScreenNameEvent(self.className())
        
        checkTracksAvailable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Notification
    
    func applicationDidBecomeActive() {
        checkTracksAvailable()
    }
    
    // MARK: - Private
    
    private func checkTracksAvailable() {
        if musicPlayer.numOfTracks == 0 {
            threwError(musicPlayer, error: MusicPlayer.Error.NoMusic)
        }
    }
    
    private func updateSeekingControls() {
        if musicPlayer.repeatMode == MusicPlayer.RepeatMode.All {
            controlsView.enablePrevious(true)
            controlsView.enableNext(true)
            return
        }
        
        let trackNumber = musicPlayer.currentTrackNumber
        if trackNumber == 0 {
            controlsView.enablePrevious(false)
            controlsView.enableSeekBackwardsRemoteOnly(true)
        }
        if (trackNumber == musicPlayer.numOfTracks - 1) {
            controlsView.enableNext(false)
            controlsView.enableSeekForwardsRemoteOnly(true)
        }
    }
}

// MARK: - MusicPlayerDelegate

extension PlayerViewController: MusicPlayerDelegate {
    func changedState(sender: MusicPlayer, state: MusicPlayer.State) {
        switch state {
        case .Playing:
            controlsView.setControlsPlaying()
            infoView.setInfoFromTrack(sender.currentResolvedTrack)
            infoView.setTrackPosition((musicPlayer.currentTrackNumber + 1), totalTracks: musicPlayer.numOfTracks)
            scrobbleView.userInteractionEnabled = true
            updateSeekingControls()
            break
        case .Paused:
            controlsView.setControlsPaused()
            scrobbleView.userInteractionEnabled = false
            break
        case .Stopped:
            controlsView.setControlsStopped()
            scrobbleView.userInteractionEnabled = false
            break
        case .Finished:
            infoView.clearInfo()
            controlsView.setControlsStopped()
            scrobbleView.userInteractionEnabled = false
            
            Analytics.shared.sendAlertEvent("finished_playlist",
                classId: self.className())
            
            let alert = AlertController.createAlertWithTitle(localized("finished alert title"),
                message: localized("finished alert msg"),
                buttonTitle: localized("finished alert button"))
            presentViewController(alert, animated: true, completion: nil)
            
            break
        }
    }
    
    func changedPlaybackTime(sender: MusicPlayer, playbackTime: NSTimeInterval) {
        guard userScrobbling == false else {
            return
        }
        
        let track = musicPlayer.currentTrack
        let duration = track.playbackDuration
        let perc = Float(playbackTime / duration)
        scrobbleView.scrobbleToPercentage(perc)
        infoView.setTime(playbackTime, duration: duration)
    }
    
    func threwError(sender: MusicPlayer, error: MusicPlayer.Error) {
        var alert: UIAlertController!
        
        switch error {
        case .NoMusic:
            Analytics.shared.sendAlertEvent("no_music",
                classId: self.className())
            
            alert = AlertController.createAlertWithTitle(localized("no music error title"),
                message: localized("no music error msg"),
                buttonTitle: localized("no music error button"),
                buttonAction: {
                    self.checkTracksAvailable()
            })
            break
        case .NoVolume:
            Analytics.shared.sendAlertEvent("no_volume",
                classId: self.className())
            
            alert = AlertController.createAlertWithTitle(localized("no volume error title"),
                message: localized("no volume error msg"),
                buttonTitle: localized("no volume error button"))
            break
        case .Decode, .PlayerInit, .AVError:
            Analytics.shared.sendAlertEvent("track",
                classId: self.className())
            
            let track = musicPlayer.currentResolvedTrack
            alert = AlertController.createAlertWithTitle(localized("track error title"),
                message: String(format: localized("track error msg"), track.title),
                buttonTitle: localized("track error button"),
                buttonAction: {
                    let trackNumber = self.musicPlayer.currentTrackNumber
                    if (trackNumber < self.musicPlayer.numOfTracks) {
                        self.musicPlayer.next()
                    }
            })
            break
        }
        
        presentViewController(alert, animated: true, completion: nil)
    }
}

// MARK: - ScrobbleViewDelegate

extension PlayerViewController: ScrobbleViewDelegate {
    func touchMovedToPercentage(sender: ScrobbleView, percentage: Float) {
        let track = musicPlayer.currentTrack
        let duration = track.playbackDuration
        let time = duration * NSTimeInterval(percentage)
        infoView.setTime(time, duration: duration)
        userScrobbling = true
    }
    
    func touchEndedAtPercentage(sender: ScrobbleView, percentage: Float) {
        Analytics.shared.sendButtonPressEvent("scrobble",
            classId: self.className())
        
        let track = musicPlayer.currentTrack
        let duration = track.playbackDuration
        let time = duration * NSTimeInterval(percentage)
        infoView.setTime(time, duration: duration)
        musicPlayer.time = time
        userScrobbling = false
    }
}

// MARK: - ControlsViewDelegate

extension PlayerViewController: ControlsViewDelegate {
    func playPressed(sender: ControlsView) {
        if musicPlayer.isPlaying == false {
            Analytics.shared.sendButtonPressEvent("play",
                classId: self.className())
            
            musicPlayer.play()
        } else {
            Analytics.shared.sendButtonPressEvent("pause",
                classId: self.className())
            
            musicPlayer.pause()
        }
    }
    
    func stopPressed(sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("stop",
            classId: self.className())
        
        musicPlayer.stop()
    }
    
    func prevPressed(sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("prev",
            classId: self.className())
        
        musicPlayer.previous()
    }
    
    func nextPressed(sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("next",
            classId: self.className())
        
        musicPlayer.next()
    }
    
    func shufflePressed(sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("shuffle",
            classId: self.className())
        
        musicPlayer.stop()
        musicPlayer.shuffle()
        musicPlayer.play()
    }
    
    func sharePressed(sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("share",
            classId: self.className())
        
        shareManager.shareTrack(musicPlayer.currentResolvedTrack,
            presenter: self,
            sender: sender.shareButton,
            completion: { (result: ShareManager.Result, service: String?) in
                var event: String!
                switch result {
                case .Success:
                    event = "success_\(service)"
                    break
                case .CancelledAfterChoice:
                    event = "cancelled-after-choice_\(service)"
                    break
                case .CancelledBeforeChoice:
                    event = "cancelled-before-choice_\(service)"
                    break
                case .Error:
                    event = "error_\(service)"

                    Analytics.shared.sendAlertEvent("share_account",
                        classId: self.className())
                    
                    let alert = UIAlertController.createAlertWithTitle(self.localized("accounts error title"),
                        message: self.localized("accounts error msg"),
                        buttonTitle: self.localized("accounts error button"))
                    self.presentViewController(alert, animated: true, completion: nil)
                    
                    break
                }
                
                Analytics.shared.sendShareEvent(event,
                    classId: self.className())
        })
    }
    
    func repeatPressed(sender: ControlsView) {
        let buttonState: RepeatButton.State = sender.repeatButtonState
        var newButtonState: RepeatButton.State!
        var event: String!
        
        switch buttonState {
        case .None:
            newButtonState = RepeatButton.State.One
            event = "repeat-one"
            musicPlayer.repeatMode = MusicPlayer.RepeatMode.One
        case .One:
            newButtonState = RepeatButton.State.All
            event = "repeat-all"
            musicPlayer.repeatMode = MusicPlayer.RepeatMode.All
        case .All:
            newButtonState = RepeatButton.State.None
            event = "repeat-none"
            musicPlayer.repeatMode = MusicPlayer.RepeatMode.None
        }
        
        // update ui
        sender.repeatButtonState = newButtonState
        
        if musicPlayer.isPlaying == true {
            updateSeekingControls()
        }

        // track analytics
        Analytics.shared.sendButtonPressEvent(event,
            classId: self.className())
        
        // save repeat state
        UserData.repeatMode = musicPlayer.repeatMode
    }
}

// MARK - Testing

extension PlayerViewController {
    var __musicPlayer: MusicPlayer {
        get { return musicPlayer }
        set { musicPlayer = newValue }
    }
    var __infoView: InfoView {
        get { return infoView }
        set { infoView = newValue }
    }
    var __controlsView: ControlsView {
        get { return controlsView }
        set { controlsView = newValue }
    }
    var __scrobbleView: ScrobbleView {
        get { return scrobbleView }
        set { scrobbleView = newValue }
    }
    var __shareManager: ShareManager {
        get { return shareManager }
        set { shareManager = newValue }
    }
    var __AlertController: UIAlertController.Type {
        get { return AlertController }
        set { AlertController = newValue }
    }
    var __userScrobbling: Bool {
        get { return userScrobbling }
        set { userScrobbling = newValue }
    }
}