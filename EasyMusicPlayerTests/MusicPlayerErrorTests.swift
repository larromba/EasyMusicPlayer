@testable import EasyMusic
import MediaPlayer
import TestExtensions
import XCTest

final class MusicPlayerErrorTests: XCTestCase {
    private var viewController: UIViewController!

    override func setUp() {
        super.setUp()
        viewController = UIViewController()
        UIApplication.shared.keyWindow!.rootViewController = viewController
        UIView.setAnimationsEnabled(false)
    }

    override func tearDown() {
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }

	func testNoAuthShowsError() {
        // mocks
        let env = PlayerEnvironment(authorizationStatus: .denied, alertViewController: viewController)
        env.inject()

        // sut
        env.musicService.play()
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
        let env = PlayerEnvironment(mediaItems: [], alertViewController: viewController)
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
            XCTAssertEqual(alert.message, "You have no music")
            XCTAssertEqual(alert.actions.count, 1)
            XCTAssertEqual(alert.actions.first?.title, "OK")
        }
	}

	func testNoVolumeShowsError() {
        // mocks
        let env = PlayerEnvironment(outputVolume: 0.0, alertViewController: viewController)
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
        let env = PlayerEnvironment(repeatState: .none, trackID: 2, alertViewController: viewController)
        env.inject()

        // sut
        let audioPlayer = AVAudioPlayer()
        (env.musicService as! MusicService).audioPlayerDidFinishPlaying(audioPlayer, successfully: true)

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
        let env = PlayerEnvironment(outputVolume: 0.0, alertViewController: viewController)
        env.inject()

        // sut
        let audioPlayer = AVAudioPlayer()
        (env.musicService as! MusicService).audioPlayerDecodeErrorDidOccur(audioPlayer, error: nil)

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 0)
        XCTAssertEqual(env.musicService.state.totalTracks, 2)
	}
}
