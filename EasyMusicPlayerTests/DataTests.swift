@testable import EasyMusic
import MediaPlayer
import XCTest

final class DataTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var env: PlayerEnvironment!

    override func setUp() {
        userDefaults = UserDefaults(suiteName: UUID().uuidString)
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
        XCTAssertEqual(env.userService.repeatState, .one)
    }

    func testRepeatStateLoadedOnStart() {
        // mocks
        let dataManager = DataManger(userDefaults: userDefaults)
        let userService = UserService(dataManager: dataManager)
        userService.repeatState = .all
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .all)
    }

    func testCurrentTrackIDPersistedOnTrackChange() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[0])
        env.inject()
        env.next()

        // test
        XCTAssertEqual(env.userService.currentTrackID, 1)
    }

    func testCurrentTrackIDLoadedOnStart() {
        // mocks
        env.setSavedTracks(defaultTracks, currentTrack: defaultTracks[1])
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
    }

    func testShuffleTracksPersisted() {
        // mocks
        env.setLibraryTracks(defaultTracks)
        env.inject()
        env.shuffle()

        // test
        let trackIDs = env.userService.trackIDs
        XCTAssertEqual(trackIDs?.count, defaultTracks.count)
        XCTAssertNotEqual(trackIDs, defaultTracks.map { $0.persistentID })
    }

    func testTrackIDsLoadedOnStart() {
        // mocks
        env.setLibraryTracks(defaultTracks)
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.totalTracks, defaultTracks.count)
    }
}
