@testable import EasyMusicPlayer
import XCTest

@MainActor
final class PlayerViewModelTests: XCTestCase {
    private var musicPlayer: MusicPlayableMock!
    private var urlSharer: URLSharableMock!
    private var sut: PlayerViewModel!

    override func setUpWithError() throws {
        musicPlayer = MusicPlayableMock()
        urlSharer = URLSharableMock()
        sut = PlayerViewModel(musicPlayer: musicPlayer, urlSharer: urlSharer)
    }

    override func tearDownWithError() throws {
        musicPlayer = nil
        urlSharer = nil
        sut = nil
    }

    // MARK: - authorize

    func test_authorize_whenInvoked_expectIsAuthorised() {
        sut.authorize()

        XCTAssertEqual(musicPlayer.authorizeCallCount, 1)
    }

    // MARK: - about

    func test_about_whenInvoked_expectOpensAbout() {
        sut.openAbout()

        XCTAssertEqual(urlSharer.openCallCount, 1)
    }

    // MARK: - state

    func test_state_whenErrorAuthReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.auth))

        XCTAssertEqual(sut.alert.title, L10n.authorizationErrorTitle)
        XCTAssertEqual(sut.alert.text, L10n.authorizationErrorMessage)
        XCTAssertEqual(sut.alert.buttonTitle, L10n.authorizationErrorButton)
    }

    func test_state_whenErrorFinishedReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.finished))

        XCTAssertEqual(sut.alert.title, L10n.finishedAlertTitle)
        XCTAssertEqual(sut.alert.text, L10n.finishedAlertMsg)
        XCTAssertEqual(sut.alert.buttonTitle, L10n.finishedAlertButton)
    }

    func test_state_whenNoMusicReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.noMusic))

        XCTAssertEqual(sut.alert.title, L10n.noMusicErrorTitle)
        XCTAssertEqual(sut.alert.text, L10n.noMusicErrorMsg)
        XCTAssertEqual(sut.alert.buttonTitle, L10n.noMusicErrorButton)
    }

    func test_state_whenPlayReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.play))

        XCTAssertEqual(sut.alert.title, L10n.playErrorTitle)
        XCTAssertEqual(sut.alert.text, L10n.playErrorMessage)
        XCTAssertEqual(sut.alert.buttonTitle, L10n.playErrorButton)
    }

    func test_state_whenVolumeReceived_expectAlert() {
        musicPlayer.stateSubject.send(.error(.volume))

        XCTAssertEqual(sut.alert.title, L10n.noVolumeErrorTitle)
        XCTAssertEqual(sut.alert.text, L10n.noVolumeErrorMsg)
        XCTAssertEqual(sut.alert.buttonTitle, L10n.noVolumeErrorButton)
    }
}
