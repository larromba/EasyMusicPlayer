import Combine
@preconcurrency import MediaPlayer
import UIKit

@MainActor
final class InfoViewModel: ObservableObject {
    @Published var track: MPMediaItem?
    @Published var time = ""
    @Published var position = ""

    var artist: String {
        track?.resolvedArtist ?? ""
    }
    var trackTitle: String {
        track?.resolvedTitle ?? ""
    }
    var artwork: UIImage {
        track?.artwork?.image(at: .artworkSize) ?? track?.embeddedArtwork ?? .imagePlaceholder
    }

    private let musicPlayer: MusicPlayable
    private let remote: NowPlayingInfoCenter
    private var cancellables = [AnyCancellable]()

    init(
        musicPlayer: MusicPlayable,
        remote: NowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    ) {
        self.musicPlayer = musicPlayer
        self.remote = remote

        musicPlayer.state
            .sink { [weak self] in
                guard let self else { return }
                switch $0 {
                case .play:
                    updateTrack()
                case .clock(let timeInterval):
                    updateClock(timeInterval)
                case .stop:
                    stop()
                case .reset:
                    reset()
                default:
                    break
                }
            }.store(in: &cancellables)
    }

    private func updateTrack() {
        track = musicPlayer.info.track.track
        position = L10n.trackPositionFormat(musicPlayer.info.track.number, musicPlayer.info.tracks.count)
        time = L10n.timeFormat(stringFromTimeInterval(musicPlayer.info.time))

        updateRemoteTrack()
        updateRemoteTime(musicPlayer.info.time)
    }

    private func updateClock(_ timeInterval: TimeInterval) {
        time = L10n.timeFormat(stringFromTimeInterval(timeInterval))

        updateRemoteTime(timeInterval)
    }

    private func stringFromTimeInterval(_ timeInterval: TimeInterval) -> String {
        let interval = Int(timeInterval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return L10n.timeIntervalFormat(hours, minutes, seconds)
    }

    private func stop() {
        time = L10n.timeFormat(stringFromTimeInterval(0))

        updateRemoteTime(0)
    }

    private func reset() {
        track = nil
        time = ""
        position = ""
        remote.nowPlayingInfo = [:]
    }

    private func updateRemoteTrack() {
        // FIXME: swift bug - MPMediaItemArtwork() causes a data race
        // warning: data race detected: @MainActor function at EasyMusicPlayer/InfoViewModel.swift:92 was not called on the main thread
        // see: https://stackoverflow.com/questions/78989543/swift-data-race-with-appkit-mpmediaitemartwork-function
        let artwork = self.artwork.copy() as! UIImage
        remote.nowPlayingInfo = [
            MPMediaItemPropertyTitle: trackTitle,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: .artworkSize) { @Sendable _ in artwork },
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
    }

    private func updateRemoteTime(_ timeInterval: TimeInterval) {
        guard var nowPlayingInfo = remote.nowPlayingInfo else { return }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = timeInterval
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = track?.playbackDuration ?? 0
        remote.nowPlayingInfo = nowPlayingInfo
    }
}

private extension CGSize {
    static let artworkSize = CGSize(width: 500, height: 500)
}

private extension MPMediaItem {
    var embeddedArtwork: UIImage? {
        guard let url = assetURL else {
            return nil
        }
        let asset = AVAsset(url: url)
        // TODO: use new async load() function
        guard let metadataItem = asset.commonMetadata.first(where: { $0.commonKey == .commonKeyArtwork }),
              let data = metadataItem.dataValue,
              let image = UIImage(data: data) else { return nil }
        return image
    }
}
