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
    @IBOutlet fileprivate weak var scrubberView: ScrubberView!
    @IBOutlet fileprivate weak var infoView: InfoView!
    @IBOutlet fileprivate weak var controlsView: ControlsView!
    
    fileprivate lazy var musicPlayer: MusicPlayer = MusicPlayer(delegate: self)
    fileprivate var shareManager: ShareManager = ShareManager()
    fileprivate var userScrobbling: Bool = false
    fileprivate var AlertController = UIAlertController.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlsView.delegate = self
        scrubberView.delegate = self
        
        if let repeatMode = UserData.repeatMode {
            musicPlayer.repeatMode = repeatMode
            
            switch repeatMode {
            case .none:
                controlsView.repeatButtonState = RepeatButton.State.none
                break
            case .one:
                controlsView.repeatButtonState = RepeatButton.State.one
                break
            case .all:
                controlsView.repeatButtonState = RepeatButton.State.all
                break
            }
        }
        
        NotificationCenter.default.addObserver(self,
            selector: safeSelector(Constant.Notification.ApplicationDidBecomeActive),
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
            name: NSNotification.Name.UIApplicationDidBecomeActive,
            object: nil)
    }

    override func viewDidAppear(_ animated: Bool) {
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
        
        // if play button is showing pause image, but the player isn't playing, then somthing went horribly wrong so reset the player
        if controlsView.playButton.buttonState == PlayButton.State.pause && musicPlayer.isPlaying == false {
            musicPlayer.stop()
        }
    }
    
    // MARK: - Private
    
    fileprivate func checkTracksAvailable() {
        if musicPlayer.numOfTracks == 0 {
            threwError(musicPlayer, error: MusicPlayer.MusicError.noMusic)
        }
    }
    
    fileprivate func updateSeekingControls() {
        if musicPlayer.repeatMode == MusicPlayer.RepeatMode.all {
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
    func changedState(_ sender: MusicPlayer, state: MusicPlayer.State) {
        switch state {
        case .playing:
            controlsView.setControlsPlaying()
            infoView.setInfoFromTrack(sender.currentResolvedTrack)
            infoView.setTrackPosition((musicPlayer.currentTrackNumber + 1), totalTracks: musicPlayer.numOfTracks)
            scrubberView.isUserInteractionEnabled = true
            updateSeekingControls()
            break
        case .paused:
            controlsView.setControlsPaused()
            scrubberView.isUserInteractionEnabled = false
            break
        case .stopped:
            controlsView.setControlsStopped()
            scrubberView.isUserInteractionEnabled = false
            break
        case .finished:
            infoView.clearInfo()
            controlsView.setControlsStopped()
            scrubberView.isUserInteractionEnabled = false
            
            Analytics.shared.sendAlertEvent("finished_playlist",
                classId: self.className())
            
            let alert = AlertController.createAlertWithTitle(localized("finished alert title"),
                message: localized("finished alert msg"),
                buttonTitle: localized("finished alert button"))
            present(alert, animated: true, completion: nil)
            
            break
        }
    }
    
    func changedPlaybackTime(_ sender: MusicPlayer, playbackTime: TimeInterval) {
        guard userScrobbling == false else {
            return
        }
        
        let track = musicPlayer.currentTrack
        let duration = track.playbackDuration
        let perc = Float(playbackTime / duration)
        scrubberView.scrubberToPercentage(perc)
        infoView.setTime(playbackTime, duration: duration)
        infoView.setRemoteTime(playbackTime, duration: duration)
    }
    
    func threwError(_ sender: MusicPlayer, error: MusicPlayer.MusicError) {
        var alert: UIAlertController!
        
        switch error {
        case .noMusic:
            Analytics.shared.sendAlertEvent("no_music",
                classId: self.className())
            
            alert = AlertController.createAlertWithTitle(localized("no music error title"),
                message: localized("no music error msg"),
                buttonTitle: localized("no music error button"),
                buttonAction: {
                    self.checkTracksAvailable()
            })
            break
        case .noVolume:
            Analytics.shared.sendAlertEvent("no_volume",
                classId: self.className())
            
            alert = AlertController.createAlertWithTitle(localized("no volume error title"),
                message: localized("no volume error msg"),
                buttonTitle: localized("no volume error button"))
            break
        case .decode, .playerInit, .avError:
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
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - ScrubberViewDelegate

extension PlayerViewController: ScrubberViewDelegate {
    func touchMovedToPercentage(_ sender: ScrubberView, percentage: Float) {
        let track = musicPlayer.currentTrack
        let duration = track.playbackDuration
        let time = duration * TimeInterval(percentage)
        infoView.setTime(time, duration: duration)
        userScrobbling = true
    }
    
    func touchEndedAtPercentage(_ sender: ScrubberView, percentage: Float) {
        Analytics.shared.sendButtonPressEvent("scrubber",
            classId: self.className())
        
        let track = musicPlayer.currentTrack
        let duration = track.playbackDuration
        let time = duration * TimeInterval(percentage)
        infoView.setTime(time, duration: duration)
        infoView.setRemoteTime(time, duration: duration)
        musicPlayer.time = time
        userScrobbling = false
    }
}

// MARK: - ControlsViewDelegate

extension PlayerViewController: ControlsViewDelegate {
    func playPressed(_ sender: ControlsView) {
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
    
    func stopPressed(_ sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("stop",
            classId: self.className())
        
        musicPlayer.stop()
    }
    
    func prevPressed(_ sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("prev",
            classId: self.className())
        
        musicPlayer.previous()
    }
    
    func nextPressed(_ sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("next",
            classId: self.className())
        
        musicPlayer.next()
    }
    
    func shufflePressed(_ sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("shuffle",
            classId: self.className())
        
        musicPlayer.stop()
        musicPlayer.shuffle()
        musicPlayer.play()
    }
    
    func sharePressed(_ sender: ControlsView) {
        Analytics.shared.sendButtonPressEvent("share",
            classId: self.className())
        
        shareManager.shareTrack(musicPlayer.currentResolvedTrack,
            presenter: self,
            sender: sender.shareButton,
            completion: { (result: ShareManager.Result, service: String?) in
                var event: String!
                switch result {
                case .success:
                    event = "success_\(service)"
                    break
                case .cancelledAfterChoice:
                    event = "cancelled-after-choice_\(service)"
                    break
                case .cancelledBeforeChoice:
                    event = "cancelled-before-choice_\(service)"
                    break
                case .error:
                    event = "error_\(service)"

                    Analytics.shared.sendAlertEvent("share_account",
                        classId: self.className())
                    
                    let alert = UIAlertController.createAlertWithTitle(self.localized("accounts error title"),
                        message: self.localized("accounts error msg"),
                        buttonTitle: self.localized("accounts error button"))
                    self.present(alert, animated: true, completion: nil)
                    
                    break
                }
                
                Analytics.shared.sendShareEvent(event,
                    classId: self.className())
        })
    }
    
    func repeatPressed(_ sender: ControlsView) {
        let buttonState: RepeatButton.State = sender.repeatButtonState
        var newButtonState: RepeatButton.State!
        var event: String!
        
        switch buttonState {
        case .none:
            newButtonState = RepeatButton.State.one
            event = "repeat-one"
            musicPlayer.repeatMode = MusicPlayer.RepeatMode.one
        case .one:
            newButtonState = RepeatButton.State.all
            event = "repeat-all"
            musicPlayer.repeatMode = MusicPlayer.RepeatMode.all
        case .all:
            newButtonState = RepeatButton.State.none
            event = "repeat-none"
            musicPlayer.repeatMode = MusicPlayer.RepeatMode.none
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
    var __scrubberView: ScrubberView {
        get { return scrubberView }
        set { scrubberView = newValue }
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
