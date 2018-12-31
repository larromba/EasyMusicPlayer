@testable import EasyMusic
import MediaPlayer
import XCTest

final class DataTests: XCTestCase {
    private var userDefaults: TestUserDefaults!
    private var env: PlayerEnvironment!

    override func setUp() {
        userDefaults = TestUserDefaults()
        userDefaults.trackIDs = defaultTracks.map { $0.persistentID }
        userDefaults.currentTrackID = defaultTracks[1].persistentID
        env = PlayerEnvironment(userDefaults: userDefaults)
        super.setUp()
    }

    override func tearDown() {
        userDefaults = nil
        env = nil
        super.tearDown()
    }

    func testRepeatStatePersisted() {
        // mocks
        let controlsViewController = ControlsViewController.fromStoryboard
        env.controlsViewController = controlsViewController
        env.inject()
        env.setRepeatState(.none)

        // sut
        XCTAssertTrue(controlsViewController.repeatButton.tap())

        // test
        XCTAssertEqual(userDefaults.repeatState, .one)
    }

    func testRepeatStateLoadedOnStart() {
        // mocks
        userDefaults.repeatState = .all
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .all)
    }

    func testCurrentTrackIDPersistedOnPlay() {
        // mocks
        env.setTracks(defaultTracks, currentTrack: nil)
        env.inject()
        env.setPlaying()

        // test
        XCTAssertEqual(userDefaults.currentTrackID, 1)
    }

    func testCurrentTrackIDLoadedOnStart() {
        // mocks
        env.setTracks(defaultTracks, currentTrack: nil)
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
    }

    func testShuffleTracksPersisted() {
        // mocks
        env.setTracks(defaultTracks, currentTrack: nil)
        env.inject()

        // sut
        env.musicService.shuffle()

        // test
        let trackIDs = userDefaults.trackIDs
        XCTAssertEqual(trackIDs?.count, defaultTracks.count)
        XCTAssertNotEqual(trackIDs, defaultTracks.map { $0.persistentID })
    }

    func testTrackIDsLoadedOnStart() {
        // mocks
        env.setTracks(defaultTracks, currentTrack: nil)
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.totalTracks, defaultTracks.count)
    }
}
