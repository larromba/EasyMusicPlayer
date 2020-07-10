@testable import EasyMusic
import MediaPlayer
import TestExtensions
import XCTest

final class MusicPlayerErrorTests: XCTestCase {
    private var viewController: PlayerViewController!
    private var env: AppTestEnvironment!

    override func setUp() {
        super.setUp()
        viewController = .fromStoryboard()
        env = AppTestEnvironment(playerViewController: viewController, alertPresenter: viewController)
        UIApplication.shared.keyWindow!.rootViewController = viewController
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        viewController = nil
        env = nil
        UIApplication.shared.keyWindow!.rootViewController = nil
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }

    func test_playerError_whenNotAuthorized_expectAlertThrown() {
        // mocks
        env.setAuthorizationStatus(.denied)
        env.inject()
        env.setPlaying()

        // sut
        guard
            let invocation = MockMediaLibrary.invocations.find(MockMediaLibrary.requestAuthorization2.name).first,
            let handler = invocation.parameter(for: MockMediaLibrary.requestAuthorization2.params.handler)
                as? ((MPMediaLibraryAuthorizationStatus) -> Void) else {
                    XCTFail("expected handler")
                    return
        }
        handler(.denied)

        // test
        waitSync()
        guard let alert = self.viewController.presentedViewController as? UIAlertController else {
            XCTFail("expected UIAlertController")
            return
        }
        XCTAssertEqual(alert.title, "Authorization")
        XCTAssertEqual(alert.message, "In the Settings, please allow us access to your music!")
        XCTAssertEqual(alert.actions.count, 1)
        XCTAssertEqual(alert.actions.first?.title, "OK")
    }

    func test_playerError_whenNoTracks_expectAlertThrown() {
        // mocks
        env.setLibraryTracks([])
        env.inject()
        env.setPlaying()

        // test
        waitSync()
        guard let alert = self.viewController.presentedViewController as? UIAlertController else {
            XCTFail("expected UIAlertController")
            return
        }
        XCTAssertEqual(alert.title, "Error")
        XCTAssertEqual(alert.message, "You have no music")
        XCTAssertEqual(alert.actions.count, 1)
        XCTAssertEqual(alert.actions.first?.title, "OK")
    }

    func test_playerError_whenNoVolume_expectAlertThrown() {
        // mocks
        env.setOutputVolume(0)
        env.inject()
        env.setPlaying()

        // test
        waitSync()
        guard let alert = self.viewController.presentedViewController as? UIAlertController else {
            XCTFail("expected UIAlertController")
            return
        }
        XCTAssertEqual(alert.title, "Error")
        XCTAssertEqual(alert.message, "Your volume is too low")
        XCTAssertEqual(alert.actions.count, 1)
        XCTAssertEqual(alert.actions.first?.title, "OK")
    }

    func test_playerError_whenMusicFinished_expectAlertThrown() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[2])
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // sut
        (env.musicService as? MusicService)?.audioPlayerDidFinishPlaying(AVAudioPlayer(), successfully: true)

        // test
        waitSync()
        guard let alert = self.viewController.presentedViewController as? UIAlertController else {
            XCTFail("expected UIAlertController")
            return
        }
        XCTAssertEqual(alert.title, "End")
        XCTAssertEqual(alert.message, "Your playlist finished")
        XCTAssertEqual(alert.actions.count, 1)
        XCTAssertEqual(alert.actions.first?.title, "OK")
    }

    func test_playerError_whenDecodeError_expectRemovesTracks() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()
        env.setPlaying()

        // sut
        (env.musicService as? MusicService)?.audioPlayerDecodeErrorDidOccur(AVAudioPlayer(), error: nil)

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        XCTAssertEqual(env.musicService.state.totalTracks, 2)
    }
}
