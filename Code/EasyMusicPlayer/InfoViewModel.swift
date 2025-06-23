import Combine
@preconcurrency import MediaPlayer
import SwiftUI

@MainActor
final class InfoViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var artist: String = ""
    @Published var artwork: UIImage = .artworkPlaceholder
    @Published var time = ""
    @Published var position = ""

    private let musicPlayer: MusicPlayable
    private let remote: NowPlayingInfoCenter
    private var musicPlayerInfo: MusicPlayerInformation?
    private var artworkTask: Task<Void, Never>?
    private var cancellables = [AnyCancellable]()

    init(
        musicPlayer: MusicPlayable,
        remote: NowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    ) {
        self.musicPlayer = musicPlayer
        self.remote = remote

        setupBindings()
    }

    private func setupBindings() {
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
        let musicPlayerInfo = musicPlayer.info
        guard let mediaItem = musicPlayerInfo.trackInfo.track else {
            reset()
            return
        }
        self.musicPlayerInfo = musicPlayerInfo
        position = L10n.trackPositionFormat(musicPlayerInfo.trackInfo.number, musicPlayerInfo.tracks.count)
        time = L10n.timeFormat(stringFromTimeInterval(musicPlayerInfo.time))
        artist = mediaItem.resolvedArtist
        title = mediaItem.resolvedTitle
        artworkTask?.cancel()
        artworkTask = Task {
            artwork = .artworkPlaceholder // reset the artwork to avoid bleeding between tracks
            let artwork = await mediaItem.resolvedArtwork() // fetch the artwork asynconously
            guard !Task.isCancelled else { return }
            withAnimation { self.artwork = artwork } // set the artwork with a fade animation
            updateRemoteTrackArtwork()
        }
        updateRemoteTrack()
        updateRemoteTime(musicPlayerInfo.time)
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
        title = ""
        artist = ""
        artwork = .artworkPlaceholder
        time = ""
        position = ""
        resetRemote()
    }

    private func resetRemote() {
        remote.nowPlayingInfo = [:]
    }

    private func updateRemoteTrack() {
        var nowPlayingInfo = remote.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyArtist] = artist
        nowPlayingInfo[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue
        remote.nowPlayingInfo = nowPlayingInfo
    }

    private func updateRemoteTrackArtwork() {
        var nowPlayingInfo = remote.nowPlayingInfo ?? [String: Any]()
        // FIXME: swift bug - MPMediaItemArtwork() causes a data race
        // warning: data race detected: @MainActor function at EasyMusicPlayer/InfoViewModel.swift:92 was not called on the main thread
        // see: https://stackoverflow.com/questions/78989543/swift-data-race-with-appkit-mpmediaitemartwork-function
        if let artwork = self.artwork.copy() as? UIImage {
            let mediaItemArtwork = MPMediaItemArtwork(boundsSize: .artworkSize) { @Sendable _ in artwork }
            nowPlayingInfo[MPMediaItemPropertyArtwork] = mediaItemArtwork
        } else {
            nowPlayingInfo[MPMediaItemPropertyArtwork] = nil
        }
        remote.nowPlayingInfo = nowPlayingInfo
    }

    private func updateRemoteTime(_ timeInterval: TimeInterval) {
        var nowPlayingInfo = remote.nowPlayingInfo ?? [String: Any]()
        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = timeInterval
        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = musicPlayerInfo?.trackInfo.duration ?? 0
        remote.nowPlayingInfo = nowPlayingInfo
    }
}
