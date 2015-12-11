//
//  InfoView.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit
import MediaPlayer

@IBDesignable
class InfoView: UIView {
    @IBOutlet private weak var artistLabel: UILabel!
    @IBOutlet private weak var trackLabel: UILabel!
    @IBOutlet private weak var trackPositionLabel: UILabel!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var artworkImageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override func awakeFromNib() {
        clearInfo()
    }
 
    // MARK: - internal
    
    func setInfoFromTrack(track: Track) {
        artistLabel.text = track.artist
        trackLabel.text = track.title
        artworkImageView.image = track.artwork
        
        var mediaItemArtwork: MPMediaItemArtwork!
        if let artwork = track.artwork {
            mediaItemArtwork = MPMediaItemArtwork(image: artwork)
        } else {
            let placeholderImage = UIImage.safeImage(named: Constant.Image.Placeholder)
            mediaItemArtwork = MPMediaItemArtwork(image: placeholderImage)
        }
        
        let songInfo: [String: AnyObject] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyArtwork: mediaItemArtwork,
            MPNowPlayingInfoPropertyPlaybackRate: Float(1.0)
        ]
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
    }
    
    func clearInfo() {
        setTime(0.0, duration: 0.0)
        
        artistLabel.text = nil
        trackLabel.text = nil
        trackPositionLabel.text = nil
        artworkImageView.image = nil
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = nil
    }
    
    func setTime(time: NSTimeInterval, duration: NSTimeInterval) {
        timeLabel.text = String(
            format: localized("time format"), stringFromTimeInterval(time))
    }
    
    func setTrackPosition(trackPosition: Int, totalTracks: Int) {
        trackPositionLabel.text = String(
            format: localized("track position format"), trackPosition, totalTracks)
    }
    
    // MARK: - private
    
    private func stringFromTimeInterval(timeInterval: NSTimeInterval) -> String {
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(
            format: localized("time interval format"), hours, minutes, seconds)
    }
}

// MARK: - Testing

extension InfoView {
    var __artistLabel: UILabel { return artistLabel }
    var __trackLabel: UILabel { return trackLabel }
    var __trackPositionLabel: UILabel { return trackPositionLabel }
    var __timeLabel: UILabel { return timeLabel }
    var __artworkImageView: UIImageView { return artworkImageView }
}