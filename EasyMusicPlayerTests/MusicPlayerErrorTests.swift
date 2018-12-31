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
        env.setTracks([], currentTrack: nil)
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
        env.setOutputVolume(0)
        env.inject()
        env.setPlaying()

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
        env.setTracks(defaultTracks, currentTrack: defaultTracks[2])
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
        env.setTracks(defaultTracks, currentTrack: defaultTracks[1])
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
