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
    func playPressed(_ sender: ControlsView)
    func stopPressed(_ sender: ControlsView)
    func prevPressed(_ sender: ControlsView)
    func nextPressed(_ sender: ControlsView)
    func shufflePressed(_ sender: ControlsView)
    func sharePressed(_ sender: ControlsView)
    func repeatPressed(_ sender: ControlsView)
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
    
    @IBAction func playButtonPressed(_ sender: UIButton) {
        delegate?.playPressed(self)
    }
    
    @IBAction func stopButtonPressed(_ sender: UIButton) {
        delegate?.stopPressed(self)
    }
    
    @IBAction func prevButtonPressed(_ sender: UIButton) {
        delegate?.prevPressed(self)
    }
    
    @IBAction func nextButtonPressed(_ sender: UIButton) {
        delegate?.nextPressed(self)
    }
    
    @IBAction func shuffleButtonPressed(_ sender: UIButton) {
        delegate?.shufflePressed(self)
    }
    
    @IBAction func shareButtonPressed(_ sender: UIButton) {
        delegate?.sharePressed(self)
    }
    
    @IBAction func repeatButtonPressed(_ sender: UIButton) {
        delegate?.repeatPressed(self)
    }
    
    // MARK: - Internal
    
    func setControlsPlaying() {
        playButton.setButtonState(PlayButton.State.pause)
        setControlsEnabled(true)
    }
    
    func setControlsPaused() {
        playButton.setButtonState(PlayButton.State.play)
        
        enablePlay(true)
        enableShuffle(true)
        enableStop(true)
        
        enablePrevious(false)
        enableNext(false)
        enableShare(false)
    }
    
    func setControlsStopped() {
        playButton.setButtonState(PlayButton.State.play)
        
        enablePlay(true)
        enableShuffle(true)
        
        enablePrevious(false)
        enableNext(false)
        enableShare(false)
        enableStop(false)
    }
    
    func setControlsEnabled(_ enabled: Bool) {
        enablePrevious(enabled)
        enableNext(enabled)
        enablePlay(enabled)
        enableStop(enabled)
        enableShuffle(enabled)
        enableShare(enabled)
        enableRepeat(enabled)
    }
    
    func enablePrevious(_ enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.previousTrackCommand.isEnabled = enable
        commandCenter.seekBackwardCommand.isEnabled = enable
        prevButton.isEnabled = enable
    }
    
    func enableNext(_ enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = enable
        commandCenter.seekForwardCommand.isEnabled = enable
        nextButton.isEnabled = enable
    }
    
    func enableSeekBackwardsRemoteOnly(_ enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.previousTrackCommand.isEnabled = enable
        commandCenter.seekBackwardCommand.isEnabled = enable
    }
    
    func enableSeekForwardsRemoteOnly(_ enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.nextTrackCommand.isEnabled = enable
        commandCenter.seekForwardCommand.isEnabled = enable
    }
    
    func enablePlay(_ enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.playCommand.isEnabled = enable
        playButton.isEnabled = enable
    }
    
    func enableStop(_ enable: Bool) {
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.stopCommand.isEnabled = enable
        stopButton.isEnabled = enable
    }
    
    func enableShare(_ enable: Bool) {
        shareButton.isEnabled = enable
    }
    
    func enableShuffle(_ enable: Bool) {
        shuffleButton.isEnabled = enable
    }
    
    func enableRepeat(_ enable: Bool) {
        repeatButton.isEnabled = enable
    }
}
