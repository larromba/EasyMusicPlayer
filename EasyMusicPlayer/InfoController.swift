import Foundation
import MediaPlayer

protocol InfoControlling {
    func setInfoFromTrack(_ track: Track)
    func clearInfo()
    func setTime(_ time: TimeInterval, duration: TimeInterval)
    func setTrackPosition(_ trackPosition: Int, totalTracks: Int)
}

final class InfoController: InfoControlling {
    private let remoteInfo: NowPlayingInfoCentering
    private let viewController: InfoViewControlling

    init(viewController: InfoViewControlling, remoteInfo: NowPlayingInfoCentering) {
        self.viewController = viewController
        self.remoteInfo = remoteInfo
        setup()
    }

    func setInfoFromTrack(_ track: Track) {
        viewController.viewState = viewController.viewState?.copy(
            artist: track.artist,
            track: track.title,
            artwork: track.artwork
        )

        let trackArtwork: UIImage
        if let artwork = track.artwork {
            trackArtwork = artwork
        } else {
            trackArtwork = Asset.imagePlaceholder.image
        }
        let mediaItemArtwork = MPMediaItemArtwork(boundsSize: trackArtwork.size) { _ -> UIImage in
            return trackArtwork
        }
        let playbackTime = remoteInfo.nowPlayingInfo?[MPNowPlayingInfoPropertyElapsedPlaybackTime] ?? 0.0

        remoteInfo.nowPlayingInfo = [
            MPMediaItemPropertyTitle: track.title,
            MPMediaItemPropertyArtist: track.artist,
            MPMediaItemPropertyArtwork: mediaItemArtwork,
            MPNowPlayingInfoPropertyElapsedPlaybackTime: playbackTime,
            MPMediaItemPropertyPlaybackDuration: track.duration,
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
    }

    func clearInfo() {
        setTime(0.0, duration: 0.0)
        viewController.viewState = viewController.viewState?.copy(
            artist: nil,
            track: nil,
            trackPosition: nil,
            artwork: nil
        )
        remoteInfo.nowPlayingInfo = nil
    }

    func setTime(_ time: TimeInterval, duration: TimeInterval) {
        let timeString = L10n.timeFormat(stringFromTimeInterval(time))
        viewController.viewState = viewController.viewState?.copy(time: timeString)

        guard var songInfo = remoteInfo.nowPlayingInfo else { return }
        songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = time
        songInfo[MPMediaItemPropertyPlaybackDuration] = duration
        remoteInfo.nowPlayingInfo = songInfo
    }

    func setTrackPosition(_ trackPosition: Int, totalTracks: Int) {
        let trackPositionString = L10n.trackPositionFormat(trackPosition, totalTracks)
        viewController.viewState = viewController.viewState?.copy(trackPosition: trackPositionString)
    }

    // MARK: - Private

    private func setup() {
        viewController.viewState = InfoViewState(
            artist: nil,
            track: nil,
            trackPosition: nil,
            time: nil,
            artwork: nil
        )
        clearInfo()
    }

    private func stringFromTimeInterval(_ timeInterval: TimeInterval) -> String {
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return L10n.timeIntervalFormat(hours, minutes, seconds)
    }
}
