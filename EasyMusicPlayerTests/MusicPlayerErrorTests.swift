@testable import EasyMusic
import MediaPlayer
import TestExtensions
import XCTest

final class MusicPlayerErrorTests: XCTestCase {
    private var viewController: UIViewController!
    private var env: PlayerEnvironment!

    override func setUp() {
        super.setUp()
        viewController = UIViewController()
        env = PlayerEnvironment(alertPresenter: viewController)
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

    func testNoAuthShowsError() {
        // mocks
        let helper = PlayerEnvironmentHelper(authorizationStatus: .denied)
        env.authorizerType = helper.authorizerType
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
        handler(helper.authorizationStatus)

        // test
        wait(for: 0.5) {
            guard let alert = self.viewController.presentedViewController as? UIAlertController else {
                XCTFail("expected UIAlertController")
                return
            }
            XCTAssertEqual(alert.title, "Authorization")
            XCTAssertEqual(alert.message, "In the Settings, please allow us access to your music!")
            XCTAssertEqual(alert.actions.count, 1)
            XCTAssertEqual(alert.actions.first?.title, "OK")
        }
    }

    func testNoTracksShowsError() {
        // mocks
        let helper = PlayerEnvironmentHelper(tracks: [])
        env.mediaQueryType = helper.mediaQueryType
        env.inject()
        env.setPlaying()

        // test
        wait(for: 0.5) {
            guard let alert = self.viewController.presentedViewController as? UIAlertController else {
                XCTFail("expected UIAlertController")
                return
            }
            XCTAssertEqual(alert.title, "Error")
            XCTAssertEqual(alert.message, "You have no music")
            XCTAssertEqual(alert.actions.count, 1)
            XCTAssertEqual(alert.actions.first?.title, "OK")
        }
    }

    func testNoVolumeShowsError() {
        // mocks
        let helper = PlayerEnvironmentHelper(volume: 0)
        env.audioSession = helper.audioSession
        env.inject()

        // sut
        env.musicService.play()

        // test
        wait(for: 0.5) {
            guard let alert = self.viewController.presentedViewController as? UIAlertController else {
                XCTFail("expected UIAlertController")
                return
            }
            XCTAssertEqual(alert.title, "Error")
            XCTAssertEqual(alert.message, "Your volume is too low")
            XCTAssertEqual(alert.actions.count, 1)
            XCTAssertEqual(alert.actions.first?.title, "OK")
        }
    }

    func testMusicFinishedShowsAlert() {
        // mocks
        let helper = PlayerEnvironmentHelper(currentTrackID: 2)
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setRepeatState(.none)
        env.setPlaying()

        // sut
        let audioPlayer = AVAudioPlayer()
        (env.musicService as! MusicService).audioPlayerDidFinishPlaying(audioPlayer, successfully: true) // TODO: ?

        // test
        wait(for: 0.5) {
            guard let alert = self.viewController.presentedViewController as? UIAlertController else {
                XCTFail("expected UIAlertController")
                return
            }
            XCTAssertEqual(alert.title, "End")
            XCTAssertEqual(alert.message, "Your playlist finished")
            XCTAssertEqual(alert.actions.count, 1)
            XCTAssertEqual(alert.actions.first?.title, "OK")
        }
    }

    func testDecodeErrorRemovesTrack() {
        // mocks
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.userDefaults = helper.userDefaults
        env.inject()
        env.setPlaying()

        // sut
        let audioPlayer = AVAudioPlayer()
        (env.musicService as! MusicService).audioPlayerDecodeErrorDidOccur(audioPlayer, error: nil) // TODO: ?

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
        XCTAssertEqual(env.musicService.state.totalTracks, 2)
    }
}
