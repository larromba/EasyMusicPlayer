import AVFoundation
@testable import EasyMusic
import TestExtensions
import XCTest

final class EndSilenceTests: XCTestCase {
    private var viewController: PlayerViewController!
    private var env: AppTestEnvironment!

    override func setUp() {
        viewController = .fromStoryboard()
        env = AppTestEnvironment(playerViewController: viewController, alertPresenter: viewController)
        UIApplication.shared.keyWindow!.rootViewController = viewController
        UIView.setAnimationsEnabled(false)
        super.setUp()
    }

    override func tearDown() {
        viewController = nil
        env = nil
        UIApplication.shared.keyWindow!.rootViewController = nil
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }

    func test_duration_whenTrackWithEndSilenceLoaded_expectReducedDuration() {
        // mocks
        class DummyDelegate: DurationDelegate {
            func duration(_ duration: Duration, didUpdateTime time: TimeInterval) {}
        }
        let assetUrl = DummyAsset.endSilence.url
        let durationDel = DummyDelegate()

        // sut
        let duration = Duration(DummyAsset.endSilence.playbackDuration, url: assetUrl, delegate: durationDel)

        // test
        waitSync()
        XCTAssertNotEqual(duration.value, DummyAsset.endSilence.playbackDuration)
        XCTAssertEqual(duration.value, 4.0, accuracy: 1.0)
    }

    func test_musicService_whenTrackWithEndSilenceLoaded_expectFinishedStateTriggered() {
        // mock
        env.playerFactory = AudioPlayerFactory()
        env.setLibraryTracks([DummyMediaItem(.endSilence, persistentID: 0)])
        env.inject()

        // sut
        env.setPlaying()
        env.musicService.setTime(3.0)

        // test
        waitSync(for: 2.0)
        guard let alert = viewController.presentedViewController as? UIAlertController else {
            XCTFail("expected UIAlertController")
            return
        }
        XCTAssertEqual(alert.title, "End")
    }
}
