//
//  ControlsView.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit
import MediaPlayer

protocol ControlsViewDelegate: class {
    func playPressed(sender: ControlsView)
    func stopPressed(sender: ControlsView)
    func prevPressed(sender: ControlsView)
    func nextPressed(sender: ControlsView)
    func shufflePressed(sender: ControlsView)
    func sharePressed(sender: ControlsView)
    func repeatPressed(sender: ControlsView)
}

@IBDesignable
class ControlsView: UIView {
    @IBOutlet weak var playButton: PlayButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var prevButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var shuffleButton: ShuffleButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var repeatButton: RepeatButton!
    
    weak var delegate: ControlsViewDelegate?
    var repeatButtonState: RepeatButton.State {
        set {
            repeatButton.setButtonState(newValue)
        }
        get {
            return repeatButton.buttonState
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override func awakeFromNib() {        
        setControlsStopped()
    }
    
    // MARK: - IBAction
    
    @IBAction func playButtonPressed(sender: UIButton) {
        delegate?.playPressed(self)
    }
    
    @IBAction func stopButtonPressed(sender: UIButton) {
        delegate?.stopPressed(self)
    }
    
    @IBAction func prevButtonPressed(sender: UIButton) {
        delegate?.prevPressed(self)
    }
    
    @IBAction func nextButtonPressed(sender: UIButton) {
        delegate?.nextPressed(self)
    }
    
    @IBAction func shuffleButtonPressed(sender: UIButton) {
        delegate?.shufflePressed(self)
    }
    
    @IBAction func shareButtonPressed(sender: UIButton) {
        delegate?.sharePressed(self)
    }
    
    @IBAction func repeatButtonPressed(sender: UIButton) {
        delegate?.repeatPressed(self)
    }
    
    // MARK: - Internal
    
    func setControlsPlaying() {
        playButton.setButtonState(PlayButton.State.Pause)
        setControlsEnabled(true)
    }
    
    func setControlsPaused() {
        playButton.setButtonState(PlayButton.State.Play)
        
        enablePlay(true)
        enableShuffle(true)
        enableStop(true)
        
        enablePrevious(false)
        enableNext(false)
        enableShare(false)
    }
    
    func setControlsStopped() {
        playButton.setButtonState(PlayButton.State.Play)
        
        enablePlay(true)
        enableShuffle(true)
        
        enablePrevious(false)
        enableNext(false)
        enableShare(false)
        enableStop(false)
    }
    
    func setControlsEnabled(enabled: Bool) {
        enablePrevious(enabled)
        enableNext(enabled)
        enablePlay(enabled)
        enableStop(enabled)
        enableShuffle(enabled)
        enableShare(enabled)
        enableRepeat(enabled)
    }
    
    func enablePrevious(enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
        commandCenter.previousTrackCommand.enabled = enable
        commandCenter.seekBackwardCommand.enabled = enable
        prevButton.enabled = enable
    }
    
    func enableNext(enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
        commandCenter.nextTrackCommand.enabled = enable
        commandCenter.seekForwardCommand.enabled = enable
        nextButton.enabled = enable
    }
    
    func enableSeekBackwardsRemoteOnly(enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
        commandCenter.previousTrackCommand.enabled = enable
        commandCenter.seekBackwardCommand.enabled = enable
    }
    
    func enableSeekForwardsRemoteOnly(enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
        commandCenter.nextTrackCommand.enabled = enable
        commandCenter.seekForwardCommand.enabled = enable
    }
    
    func enablePlay(enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
        commandCenter.playCommand.enabled = enable
        playButton.enabled = enable
    }
    
    func enableStop(enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.sharedCommandCenter();
        commandCenter.stopCommand.enabled = enable
        stopButton.enabled = enable
    }
    
    func enableShare(enable: Bool) {
        shareButton.enabled = enable
    }
    
    func enableShuffle(enable: Bool) {
        shuffleButton.enabled = enable
    }
    
    func enableRepeat(enable: Bool) {
        repeatButton.enabled = enable
    }
}