//
//  InfoView.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

@IBDesignable
class InfoView: UIView {
    @IBOutlet var artist: UILabel!
    @IBOutlet var track: UILabel!
    @IBOutlet var time: UILabel!
    @IBOutlet var artwork: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    override func awakeFromNib() {
        clearTrackInfo()
    }
 
    // MARK: - Public
    
    func setTrackInfo(trackInfo: TrackInfo) {
        artist.text = trackInfo.artist
        track.text = trackInfo.title
        artwork.image = trackInfo.artwork
    }
    
    func clearTrackInfo() {
        setTime(0.0, duration: 0.0)
        artist.text = nil
        track.text = nil
        artwork.image = nil
    }
    
    func setTime(time: NSTimeInterval, duration: NSTimeInterval) {
        self.time.text = String(
            format: localized("time format"),
            stringFromTimeInterval(time))
    }
    
    // MARK: - Private
    
    private func stringFromTimeInterval(timeInterval: NSTimeInterval) -> String {
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(
            format: localized("time interval format"),
            hours, minutes, seconds)
    }
}