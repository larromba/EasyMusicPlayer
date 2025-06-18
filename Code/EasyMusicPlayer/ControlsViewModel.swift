import Combine
import MediaPlayer
import SwiftUI

@MainActor
final class ControlsViewModel: ObservableObject {
    @Published var playButton = MusicPlayerButton(
        image: .playButton, accessibilityLabel: "Play", isDisabled: false
    )
    @Published var stopButton = MusicPlayerButton(
        image: .stopButton, accessibilityLabel: "Stop", isDisabled: true
    )
    @Published var nextButton = MusicPlayerButton(
        image: .nextButton, accessibilityLabel: "Next", isDisabled: true
    )
    @Published var previousButton = MusicPlayerButton(
        image: .previousButton, accessibilityLabel: "Previous", isDisabled: true
    )
    @Published var repeatButton = MusicPlayerButton(
        image: .repeatButton, accessibilityLabel: "Repeat", isDisabled: false
    )
    @Published var searchButton = MusicPlayerButton(
        image: .searchButton, accessibilityLabel: "Search", isDisabled: false
    )
    @Published var shuffleButton = MusicPlayerButton(
        image: .shuffleButton, accessibilityLabel: "Shuffle", isDisabled: false, maxRotation: 360
    )

    private let musicPlayer: MusicPlayable
    private let soundEffects: SoundEffecting
    private let remote: MPRemoteCommandCenter
    private let searchAction: (() -> Void)
    private var cancellables = [AnyCancellable]()

    private var isPreviousButtonDisabled: Bool {
        let musicPlayerInfo = musicPlayer.info
        switch musicPlayerInfo.repeatMode {
        case .none:
            return musicPlayerInfo.trackInfo.index - 1 < 0
        default:
            return false
        }
    }
    private var isNextButtonDisabled: Bool {
        let musicPlayerInfo = musicPlayer.info
        switch musicPlayerInfo.repeatMode {
        case .none:
            return musicPlayerInfo.trackInfo.index + 1 >= musicPlayerInfo.tracks.count
        default:
            return false
        }
    }

    init(
        musicPlayer: MusicPlayable,
        remote: MPRemoteCommandCenter = .shared(),
        soundEffects: SoundEffecting,
        searchAction: @escaping (() -> Void)
    ) {
        self.musicPlayer = musicPlayer
        self.soundEffects = soundEffects
        self.remote = remote
        self.searchAction = searchAction

        musicPlayer.state.sink { [weak self] in
            self?.update($0)
        }.store(in: &cancellables)
    }

    func play() {
        if !musicPlayer.info.isPlaying {
            soundEffects.play(.play)
        }
        musicPlayer.togglePlayPause()
    }

    func stop() {
        soundEffects.play(.stop)
        musicPlayer.stop()
    }

    func previous() {
        guard !previousButton.isDisabled else { return }
        soundEffects.play(.prev)
        musicPlayer.previous()
    }

    func next() {
        guard !nextButton.isDisabled else { return }
        soundEffects.play(.next)
        musicPlayer.next()
    }

    func search() {
        soundEffects.play(.search)
        searchAction()
    }

    func shuffle() {
        soundEffects.play(.shuffle)
        musicPlayer.shuffle()
    }

    func toggleRepeatMode() {
        soundEffects.play(.repeat)
        musicPlayer.toggleRepeatMode()
    }

    func startSeeking(_ direction: SeekDirection) {
        musicPlayer.startSeeking(direction)
    }

    func stopSeeking() {
        musicPlayer.stopSeeking()
    }

    func toggle() {
        guard musicPlayer.info.isPlaying else { return }
        soundEffects.play(.toggle)
        playButton.image = .toggle
    }

    private func update(_ state: MusicPlayerState) {
        searchButton.isDisabled = musicPlayer.info.tracks.count == 0

        switch state {
        case .play:
            playButton.image = .pauseButton
            stopButton.isDisabled = false
            remote.stopCommand.isEnabled = true
            updateNavigationControls()
        case .pause:
            playButton.image = .playButton
            stopButton.isDisabled = false
            remote.stopCommand.isEnabled = true
            updateNavigationControls()
        case .stop, .reset:
            playButton.image = .playButton
            stopButton.isDisabled = true
            remote.stopCommand.isEnabled = false
            updateNavigationControls()
        case .repeatMode(let mode):
            remote.changeRepeatModeCommand.currentRepeatType = mode.remote
            updateNavigationControls()
            switch mode {
            case .all:
                repeatButton.image = .repeatAllButton
            case .none:
                repeatButton.image = .repeatButton
            case .one:
                repeatButton.image = .repeatOneButton
            }
        default:
            break
        }
    }

    private func updateNavigationControls() {
        previousButton.isDisabled = isPreviousButtonDisabled
        remote.previousTrackCommand.isEnabled = !previousButton.isDisabled

        nextButton.isDisabled = isNextButtonDisabled
        remote.nextTrackCommand.isEnabled = !nextButton.isDisabled
    }
}
