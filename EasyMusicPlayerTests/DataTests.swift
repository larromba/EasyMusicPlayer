@testable import EasyMusic
import MediaPlayer
import XCTest

final class DataTests: XCTestCase {
    private var userDefaults: TestUserDefaults!
    private var env: PlayerEnvironment!

    override func setUp() {
        userDefaults = TestUserDefaults()
        userDefaults.trackIDs = PlayerEnvironmentHelper().tracks.map { $0.persistentID }
        userDefaults.currentTrackID = PlayerEnvironmentHelper().currentTrackID
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
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.inject()
        env.setPlaying()

        // test
        XCTAssertEqual(userDefaults.currentTrackID, 1)
    }

    func testCurrentTrackIDLoadedOnStart() {
        // mocks
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
    }

    func testShuffleTracksPersisted() {
        // mocks
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.inject()

        // sut
        env.musicService.shuffle()

        // test
        let trackIDs = userDefaults.trackIDs
        XCTAssertEqual(trackIDs?.count, helper.tracks.count)
        XCTAssertNotEqual(trackIDs, helper.tracks.map { $0.persistentID })
    }

    func testTrackIDsLoadedOnStart() {
        // mocks
        let helper = PlayerEnvironmentHelper()
        env.mediaQueryType = helper.mediaQueryType
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.totalTracks, 3)
    }
}
