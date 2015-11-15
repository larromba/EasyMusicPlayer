//
//  MusicPlayerViewController.swift
//  EasyMusic
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

class MusicPlayerViewController: UIViewController {
    private lazy var musicPlayer: MusicPlayer! = MusicPlayer(delegate: self)
    private let shareManager: ShareManager! = ShareManager()
    
    @IBOutlet private(set) weak var scrobbleView: ScrobbleView!
    @IBOutlet private(set) weak var infoView: InfoView!
    @IBOutlet private(set) weak var controlsView: ControlsView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        controlsView.delegate = self
        scrobbleView.delegate = self
                
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: safeSelector(Constants.Notifications.ApplicationDidBecomeActive),
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
        let alert = UIAlertController.createAlertWithTitle(localized("no music error title"),
            message: localized("no music error msg"),
            buttonTitle: localized("no music error button"))
        return alert
    }
    
    private func playerError() -> UIAlertController {
        let alert = UIAlertController.createAlertWithTitle(localized("player error title"),
            message: localized("player error msg"),
            buttonTitle: localized("player error button"))
        return alert
    }
    
    private func finishedPlaylistAlert() -> UIAlertController {
        let alert = UIAlertController.createAlertWithTitle(localized("finished alert title"),
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
        if musicPlayer.hasTracks() == false {
            showError(noMusicError())
        } else {
            controlsView.setControlsStopped()
            scrobbleView.enabled = true
        }
    }
}

// MARK: - MusicPlayerDelegate
extension MusicPlayerViewController: MusicPlayerDelegate {
    func changedState(sender: MusicPlayer, state: MusicPlayerState) {
        let tracksInfo = sender.tracksInfo()

        if state == MusicPlayerState.Playing {
            controlsView.setControlsPlaying()
            infoView.setTrackInfo(tracksInfo.trackInfo)
            scrobbleView.enabled = true
        } else if state ==  MusicPlayerState.Paused {
            controlsView.setControlsPaused()
            scrobbleView.enabled = false
        } else if state == MusicPlayerState.Stopped {
            controlsView.setControlsStopped()
            scrobbleView.enabled = false
        } else if state == MusicPlayerState.Finished {
            controlsView.setControlsStopped()
            scrobbleView.enabled = false
            showAlert(finishedPlaylistAlert())
        } else {
            showError(playerError())
        }
        
        if tracksInfo.trackIndex == 0 {
            controlsView.enablePrevious(false)
        }
        if (tracksInfo.trackIndex == tracksInfo.totalTracks - 1) {
            controlsView.enableNext(false)
        }
    }
    
    func changedPlaybackTime(sender: MusicPlayer, playbackTime: NSTimeInterval) {
        let track = musicPlayer.trackInfo()
        let perc = Float(playbackTime / track.duration!)
        scrobbleView.scrobbleToPercentage(perc)
        infoView.setTime(playbackTime, duration: track.duration!)
    }
}

// MARK: - ScrobbleViewDelegate
extension MusicPlayerViewController: ScrobbleViewDelegate {
    func touchMovedToPercentage(sender: ScrobbleView, percentage: Float) {
        let track = musicPlayer.trackInfo()
        let time = track.duration! * NSTimeInterval(percentage)
        musicPlayer.skipTo(time)
        infoView.setTime(time, duration: track.duration!)
    }
}

// MARK: - ControlsViewDelegate
extension MusicPlayerViewController: ControlsViewDelegate {
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
        
        if musicPlayer.shuffle() == false {
            showError(noMusicError())
            return
        }
        
        musicPlayer.play()
    }
    
    func sharePressed(sender: ControlsView) {
        shareManager.shareTrackInfo(musicPlayer.trackInfo(), presenter: self)
    }
}