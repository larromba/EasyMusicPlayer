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
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var trackLabel: UILabel!
    @IBOutlet weak var trackPositionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    
    private let remoteInfo: MPNowPlayingInfoCenter = .default()
    
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
 
    // MARK: - Internal
    
    func setInfoFromTrack(_ track: Track) {
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
        
        var songInfo: [String: Any] = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyArtwork: mediaItemArtwork,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: remoteInfo.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] ?? NSNumber(value: 0.0),
            MPMediaItemPropertyPlaybackDuration: NSNumber(value: track.duration)
        ]
        if #available(iOS 10.0, *) {
            songInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        }
        remoteInfo.nowPlayingInfo = songInfo
    }
    
    func clearInfo() {
        setTime(0.0, duration: 0.0)
        
        artistLabel.text = nil
        trackLabel.text = nil
        trackPositionLabel.text = nil
        artworkImageView.image = nil
        
        remoteInfo.nowPlayingInfo = nil
    }

    func setTime(_ time: TimeInterval, duration: TimeInterval) {
        timeLabel.text = String(format: localized("time format", classId: classForCoder), stringFromTimeInterval(time))
    }
    
    func setRemoteTime(_ time: TimeInterval, duration: TimeInterval) {
        guard var songInfo = remoteInfo.nowPlayingInfo else {
            return
        }
        songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = NSNumber(value: time)
        remoteInfo.nowPlayingInfo = songInfo
    }
    
    func setTrackPosition(_ trackPosition: Int, totalTracks: Int) {
        trackPositionLabel.text = String(format: localized("track position format", classId: classForCoder), trackPosition, totalTracks)
    }
    
    // MARK: - Private
    
    private func stringFromTimeInterval(_ timeInterval: TimeInterval) -> String {
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: localized("time interval format", classId: classForCoder), hours, minutes, seconds)
    }
}
