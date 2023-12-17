import Combine
import MediaPlayer
import UIKit

@MainActor
final class InfoViewModel: ObservableObject {
    @Published var item: MPMediaItem?
    @Published var time = ""
    @Published var position = ""

    var artist: String {
        item?.resolvedArtist ?? ""
    }
    var track: String {
        item?.resolvedTitle ?? ""
    }
    var artwork: UIImage {
        item?.artwork?.image(at: .artwork) ?? .imagePlaceholder
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

        musicPlayer.state.sink { [weak self] in
            guard let self else { return }
            switch $0 {
            case .play:
                updateTrack()
            case .clock(let timeInterval):
                updateClock(timeInterval)
            case .stop:
                stop()
            default:
                break
            }
        }.store(in: &cancellables)
    }

    private func updateTrack() {
        item = musicPlayer.info.track.item
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
    }

    private func updateRemoteTrack() {
        remote.nowPlayingInfo = [
            MPMediaItemPropertyTitle: track,
            MPMediaItemPropertyArtist: artist,
            MPMediaItemPropertyArtwork: MPMediaItemArtwork(boundsSize: .artwork) { _ in self.artwork },
            MPNowPlayingInfoPropertyMediaType: MPNowPlayingInfoMediaType.audio.rawValue
        ]
    }

    private func updateRemoteTime(_ timeInterval: TimeInterval) {
        guard var nowPlayingInfo = remote.nowPlayingInfo else { return }
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = timeInterval
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = item?.playbackDuration ?? 0
        remote.nowPlayingInfo = nowPlayingInfo
    }
}

private extension CGSize {
    static let artwork = CGSize(width: 500, height: 500)
}
