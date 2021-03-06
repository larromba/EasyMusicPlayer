@testable import EasyMusic
import TestExtensions
import XCTest

final class SilenceDetectionTests: XCTestCase {
    private var viewController: PlayerViewController!
    private var env: AppTestEnvironment!

    override func setUp() {
        super.setUp()
        UIView.setAnimationsEnabled(false)
        viewController = .fromStoryboard()
        env = AppTestEnvironment(playerViewController: viewController, alertPresenter: viewController)
        UIApplication.shared.keyWindow!.rootViewController = viewController
    }

    override func tearDown() {
        viewController = nil
        env = nil
        UIView.setAnimationsEnabled(true)
        super.tearDown()
    }

    func test_trackManager_whenTrackWithEndSilenceLoaded_expectReducedDuration() {
        // mocks
        final class Delegate: TrackManagerDelegate {
            var track: Track?

            func trackManager(_ manager: TrackManaging, updatedTrack track: Track) {
                self.track = track
            }
        }
        let delegate = Delegate() // needs strong reference to avoid deallocation
        let mediaItem = DummyMediaItem(asset: .endSilence)
        env.setSavedTracks([mediaItem], currentTrack: mediaItem)
        env.inject()
        env.trackManager.setDelegate(delegate)

        // sut
        let originalTrack = env.trackManager.currentTrack

        // test
        waitSync(for: 3.0)
        XCTAssertLessThan(delegate.track?.duration ?? 0.0, originalTrack?.playbackDuration ?? -1.0)
        XCTAssertEqual(delegate.track?.duration ?? 0.0, 4.0, accuracy: 1.0)
    }

    #if !TRAVIS
    // AVAudioPlayer will always fail on travis
    // see https://stackoverflow.com/questions/40172431/avplayer-fails-to-load-files-during-unit-tests-on-ci-servers
    func test_musicService_whenTrackWithEndSilenceLoaded_expectFinishedStateTriggeredEarlier() {
        // mock
        env.playerFactory = AudioPlayerFactory()
        let mediaItem = DummyMediaItem(asset: .endSilence)
        env.setSavedTracks([mediaItem], currentTrack: mediaItem) // normally 17 seconds
        env.inject()

        // sut
        env.setPlaying()
        env.musicService.setTime(3.0)

        // test
        waitSync(for: 2.0)
        XCTAssertEqual(env.musicService.state.playState, .finished)
    }
    #endif
}
