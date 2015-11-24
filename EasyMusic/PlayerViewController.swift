//
//  PlayerViewController.swift
//  EasyMusic
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {
    @IBOutlet private(set) weak var scrobbleView: ScrobbleView!
    @IBOutlet private(set) weak var infoView: InfoView!
    @IBOutlet private(set) weak var controlsView: ControlsView!
    
    private lazy var musicPlayer: MusicPlayer! = MusicPlayer(delegate: self)
    private var shareManager: ShareManager! = ShareManager()
    private var userScrobbling: Bool! = false
    private var AlertController = UIAlertController.self
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlsView.delegate = self
        scrobbleView.delegate = self
        
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
        
        checkTracksAvailable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - notification
    
    func applicationDidBecomeActive() {
        checkTracksAvailable()
    }
    
    // MARK: - private

    private func noMusicError() -> UIAlertController {
        let alert = AlertController.createAlertWithTitle(localized("no music error title"),
            message: localized("no music error msg"),
            buttonTitle: localized("no music error button"))
        return alert
    }

    private func trackError() -> UIAlertController {
        let track = musicPlayer.currentTrack()
        let alert = AlertController.createAlertWithTitle(localized("track error title"),
            message: String(localized("track error msg"), track.title),
            buttonTitle: localized("track error button"))
        return alert
    }
    
    private func avError() -> UIAlertController {
        let alert = AlertController.createAlertWithTitle(localized("av error title"),
            message: localized("av error msg"),
            buttonTitle: localized("av error button"),
            buttonAction: {
                self.musicPlayer.enableAudioSession(true)
        })
        return alert
    }
    
    private func finishedPlaylistAlert() -> UIAlertController {
        let alert = AlertController.createAlertWithTitle(localized("finished alert title"),
            message: localized("finished alert msg"),
            buttonTitle: localized("finished alert button"))
        return alert
    }
    
    private func showError(error: UIAlertController) {
        controlsView.setControlsEnabled(false)
        scrobbleView.enabled = false
        presentViewController(error, animated: true, completion: nil)
    }
    
    private func showAlert(alert: UIAlertController) {
        presentViewController(alert, animated: true, completion: nil)
    }
    
    private func checkTracksAvailable() {
        if musicPlayer.numOfTracks() == 0 {
            showError(noMusicError())
        } else {
            controlsView.setControlsStopped()
        }
    }
}

// MARK: - MusicPlayerDelegate
extension PlayerViewController: MusicPlayerDelegate {
    func changedState(sender: MusicPlayer, state: MusicPlayerState) {
        switch state {
        case .Playing:
            controlsView.setControlsPlaying()
            infoView.setInfoFromTrack(sender.currentTrack())
            scrobbleView.enabled = true
            break
        case .Paused:
            controlsView.setControlsPaused()
            scrobbleView.enabled = false
            break
        case .Stopped:
            controlsView.setControlsStopped()
            scrobbleView.enabled = false
            break
        case .Finished:
            controlsView.setControlsStopped()
            scrobbleView.enabled = false
            showAlert(finishedPlaylistAlert())
            break
        }
        
        let trackNumber = musicPlayer.currentTrackNumber()
        if trackNumber == 0 {
            controlsView.enablePrevious(false)
        }
        if (trackNumber == musicPlayer.numOfTracks() - 1) {
            controlsView.enableNext(false)
        }
    }
    
    func changedPlaybackTime(sender: MusicPlayer, playbackTime: NSTimeInterval) {
        guard userScrobbling == false else {
            return
        }
        
        let track = musicPlayer.currentTrack()
        let perc = Float(playbackTime / track.duration!)
        scrobbleView.scrobbleToPercentage(perc)
        infoView.setTime(playbackTime, duration: track.duration!)
    }
    
    func threwError(sender: MusicPlayer, error: MusicPlayerError) {
        switch error {
        case .NoMusic:
            showError(noMusicError())
            break
        case .Decode, .PlayerInit:
            showError(trackError())
            
            let trackNumber = self.musicPlayer.currentTrackNumber()
            if (trackNumber < self.musicPlayer.numOfTracks() - 1) {
                self.musicPlayer.next()
            }
            break
        case .AVError:
            showError(avError())
            break
        }
    }
}

// MARK: - ScrobbleViewDelegate
extension PlayerViewController: ScrobbleViewDelegate {
    func touchMovedToPercentage(sender: ScrobbleView, percentage: Float) {
        let track = musicPlayer.currentTrack()
        let time = track.duration! * NSTimeInterval(percentage)
        infoView.setTime(time, duration: track.duration!)
        userScrobbling = true
    }
    
    func touchEndedAtPercentage(sender: ScrobbleView, percentage: Float) {
        let track = musicPlayer.currentTrack()
        let time = track.duration! * NSTimeInterval(percentage)
        infoView.setTime(time, duration: track.duration!)
        musicPlayer.skipTo(time)
        userScrobbling = false
    }
}

// MARK: - ControlsViewDelegate
extension PlayerViewController: ControlsViewDelegate {
    func playPressed(sender: ControlsView) {
        if musicPlayer.isPlaying == false {
            musicPlayer.play()
        } else {
            musicPlayer.pause()
        }
    }
    
    func stopPressed(sender: ControlsView) {
        musicPlayer.stop()
    }
    
    func prevPressed(sender: ControlsView) {
        musicPlayer.previous()
    }
    
    func nextPressed(sender: ControlsView) {
        musicPlayer.next()
    }
    
    func shufflePressed(sender: ControlsView) {
        musicPlayer.stop()
        musicPlayer.shuffle()
        musicPlayer.play()
    }
    
    func sharePressed(sender: ControlsView) {
        shareManager.shareTrack(musicPlayer.currentTrack(), presenter: self)
    }
}

// MARK - Testing
extension PlayerViewController {
    func _injectMusicPlayer(musicPlayer: MusicPlayer) {
        self.musicPlayer = musicPlayer
    }
    
    func _injectInfoView(infoView: InfoView) {
        self.infoView = infoView
    }
    
    func _injectControlsView(controlsView: ControlsView) {
        self.controlsView = controlsView
    }
    
    func _injectScrobbleView(scrobbleView: ScrobbleView) {
        self.scrobbleView = scrobbleView
    }
    
    func _injectAlertController(alertController: UIAlertController.Type) {
        self.AlertController = alertController
    }
    
    func _injectShareManager(shareManager: ShareManager) {
        self.shareManager = shareManager
    }
}