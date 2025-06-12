@testable import EasyMusicPlayer
import Testing

@MainActor
@Suite(.serialized)
struct PlayerViewModelTests {
    private let musicPlayer: MusicPlayableMock
    private let urlSharer: URLSharableMock
    private let sut: PlayerViewModel

    init() {
        let musicPlayer = MusicPlayableMock()
        self.musicPlayer = musicPlayer

        let urlSharer = URLSharableMock()
        self.urlSharer = urlSharer

        sut = PlayerViewModel(musicPlayer: musicPlayer, urlSharer: urlSharer)
    }

    // MARK: - authorize

    @Test
    func authorize_whenInvoked_expectIsAuthorised() {
        sut.authorize()

        #expect(musicPlayer.authorizeCallCount == 1)
    }

    // MARK: - about

    @Test
    func about_whenInvoked_expectOpensAbout() {
        sut.openAbout()

        #expect(urlSharer.openCallCount == 1)
    }

    // MARK: - state

    @Test
    func state_whenErrorAuthReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.auth))

        #expect(sut.alert.title == L10n.authorizationErrorTitle)
        #expect(sut.alert.text == L10n.authorizationErrorMessage)
        #expect(sut.alert.buttonTitle == L10n.authorizationErrorButton)
    }

    @Test
    func state_whenErrorFinishedReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.finished))

        #expect(sut.alert.title == L10n.finishedAlertTitle)
        #expect(sut.alert.text == L10n.finishedAlertMsg)
        #expect(sut.alert.buttonTitle == L10n.finishedAlertButton)
    }

    @Test
    func state_whenNoMusicReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.noMusic))

        #expect(sut.alert.title == L10n.noMusicErrorTitle)
        #expect(sut.alert.text == L10n.noMusicErrorMsg)
        #expect(sut.alert.buttonTitle == L10n.noMusicErrorButton)
    }

    @Test
    func state_whenPlayReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.play))

        #expect(sut.alert.title == L10n.playErrorTitle)
        #expect(sut.alert.text == L10n.playErrorMessage)
        #expect(sut.alert.buttonTitle == L10n.playErrorButton)
    }

    @Test
    func state_whenVolumeReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.volume))

        #expect(sut.alert.title == L10n.noVolumeErrorTitle)
        #expect(sut.alert.text == L10n.noVolumeErrorMsg)
        #expect(sut.alert.buttonTitle == L10n.noVolumeErrorButton)
    }
}
