import AVFoundation
@testable import EasyMusic
import TestExtensions
import XCTest

final class SilenceDetectionTests: XCTestCase {
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

    func test_trackManager_whenTrackWithEndSilenceLoaded_expectReducedDuration() {
        // mocks
        class Delegate: TrackManagerDelegate {
            var track: Track?

            func trackManager(_ manager: TrackManaging, updatedTrack track: Track) {
                self.track = track
            }
        }
        let mediaItem = DummyMediaItem(asset: .endSilence)
        env.setSavedTracks([mediaItem], currentTrack: mediaItem)
        let delegate = Delegate() // needs strong reference to avoid deallocation
        env.inject()
        env.trackManager.setDelegate(delegate)

        // sut
        let track = env.trackManager.currentTrackResolved

        // test
        waitSync(for: 3.0)
        XCTAssertLessThan(delegate.track?.duration ?? 0.0, track.duration)
        XCTAssertEqual(delegate.track?.duration ?? 0.0, 4.0, accuracy: 1.0)
    }

    func test_musicService_whenTrackWithEndSilenceLoaded_expectFinishedStateTriggeredEarlier() {
        // mock
        env.playerFactory = AudioPlayerFactory()
        env.setLibraryTracks([DummyMediaItem(asset: .endSilence)]) // normally 17 seconds
        env.inject()

        // sut
        env.setPlaying()
        env.musicService.setTime(3.0)

        // test
        waitSync(for: 3.0)
        XCTAssertEqual(env.musicService.state.playState, .finished)
    }
}
