@testable import EasyMusic
import MediaPlayer
import XCTest

final class DataTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var env: AppTestEnvironment!

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: UUID().uuidString)
        env = AppTestEnvironment(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults = nil
        env = nil
        super.tearDown()
    }

    func test_repeatButton_whenPressed_expectRepeatStatePersisted() {
        // mocks
        let controlsViewController: ControlsViewController = .fromStoryboard()
        env.controlsViewController = controlsViewController
        env.inject()
        env.setRepeatState(.none)

        // sut
        XCTAssertTrue(controlsViewController.repeatButton.fire())

        // test
        XCTAssertEqual(env.userService.repeatState, .one)
    }

    func test_repeatState_whenAppOpens_expectIsLoadedFromStore() {
        // mocks
        let dataManager = DataManger(userDefaults: userDefaults)
        let userService = UserService(dataManager: dataManager)
        userService.repeatState = .all
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .all)
    }

    func test_currentTrackID_whenTrackChanged_expectIsPersisted() {
        // mocks
        env.setSavedTracks(library, currentTrack: library[0])
        env.inject()
        env.next()

        // test
        XCTAssertEqual(env.userService.currentTrackID, 1)
    }

    func test_currentTrackID_whenAppOpens_expectIsLoadedFromStore() {
        // mocks
        env.setSavedTracks(library, currentTrack: library[1])
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
    }

    func test_shuffle_whenPressed_expectTrackIDsArePersisted() {
        // mocks
        let library = (0..<100).map { DummyMediaItem(id: $0) }
        env.setLibraryTracks(library)
        env.inject()
        env.shuffle()

        // test
        let trackIDs = env.userService.trackIDs
        XCTAssertEqual(trackIDs?.count, library.count)
        XCTAssertNotEqual(trackIDs, library.map { $0.persistentID })
    }

    func test_trackIDs_whenAppOpens_expectIsLoadedFromStore() {
        // mocks
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.totalTracks, library.count)
    }
}
