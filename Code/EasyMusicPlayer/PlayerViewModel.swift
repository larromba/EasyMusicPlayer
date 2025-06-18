import Combine
import SwiftUI

@MainActor
final class PlayerViewModel: ObservableObject {
    @Published var openSearch = false
    @Published var alert: AlertModel = .empty

    let version = Bundle.appVersion

    private let musicPlayer: MusicPlayable
    private let urlSharer: URLSharable
    private let soundEffects: SoundEffects
    private var cancellables = [AnyCancellable]()

    init(
        musicPlayer: MusicPlayable = MusicPlayer(),
        urlSharer: URLSharable,
        soundEffects: SoundEffects = SoundEffects()
    ) {
        self.musicPlayer = musicPlayer
        self.urlSharer = urlSharer
        self.soundEffects = soundEffects

        setupAlert()
    }

    func authorize() {
        musicPlayer.authorize()
    }

    func openAbout() {
        urlSharer.open(.about, options: [:], completionHandler: { _ in })
    }

    private func setupAlert() {
        musicPlayer.state.sink { [weak self] state in
            guard let self else { return }

            switch state {
            case .error(let type):
                switch type {
                case .finished:
                    alert = AlertModel(
                        title: L10n.finishedAlertTitle,
                        text: L10n.finishedAlertMsg,
                        buttonTitle: L10n.finishedAlertButton
                    )
                    soundEffects.play(.finished)
                case .noMusic:
                    alert = AlertModel(
                        title: L10n.noMusicErrorTitle,
                        text: L10n.noMusicErrorMsg,
                        buttonTitle: L10n.noMusicErrorButton
                    )
                    soundEffects.play(.error)
                case .auth:
                    alert = AlertModel(
                        title: L10n.authorizationErrorTitle,
                        text: L10n.authorizationErrorMessage,
                        buttonTitle: L10n.authorizationErrorButton
                    )
                    soundEffects.play(.error)
                case .play:
                    alert = AlertModel(
                        title: L10n.playErrorTitle,
                        text: L10n.playErrorMessage,
                        buttonTitle: L10n.playErrorButton
                    )
                    soundEffects.play(.error)
                case .volume:
                    alert = AlertModel(
                        title: L10n.noVolumeErrorTitle,
                        text: L10n.noVolumeErrorMsg,
                        buttonTitle: L10n.noVolumeErrorButton
                    )
                    soundEffects.play(.error)
                }
            default:
                break
            }
        }.store(in: &cancellables)
    }
}

extension PlayerViewModel {
    var infoViewModel: InfoViewModel {
        InfoViewModel(musicPlayer: musicPlayer)
    }
    var scrubberViewModel: ScrubberViewModel {
        ScrubberViewModel(musicPlayer: musicPlayer)
    }
    var controlsViewModel: ControlsViewModel {
        ControlsViewModel(
            musicPlayer: musicPlayer,
            soundEffects: soundEffects,
            searchAction: { [weak self] in
                self?.openSearch = true
            }
        )
    }
    var searchViewModel: SearchViewModel {
        SearchViewModel(
            musicPlayer: musicPlayer,
            soundEffects: soundEffects,
            doneAction: { [weak self] in
                self?.openSearch = false
            }
        )
    }
}

private extension URL {
    static let about = URL(string: "https://github.com/larromba/easymusicplayer")!
}
