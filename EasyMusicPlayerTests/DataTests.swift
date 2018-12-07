@testable import EasyMusic
import MediaPlayer
import XCTest

final class DataTests: XCTestCase {
    private var database: UserDefaults!
    private var dataManager: DataManaging!
    private var userService: UserServicing!

    override func setUp() {
        database = UserDefaults(suiteName: "DataTests")
        dataManager = DataManger(database: database)
        userService = UserService(dataManager: dataManager)
        super.setUp()
    }

    override func tearDown() {
        database = nil
        dataManager = nil
        userService = nil
        super.tearDown()
    }

    func testRepeatStatePersisted() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, repeatState: .none, userService: userService)
        env.inject()

        // sut
        env.controlsViewController.repeatButton.tap()

        // test
        XCTAssertEqual(database.value(forKey: "repeatState") as? String, "one")
    }

    func testRepeatStateLoadedOnStart() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, repeatState: .all, userService: userService)
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.repeatState, .all)
    }

    func testCurrentTrackIDPersisted() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, trackID: 1, userService: userService)
        env.inject()

        // sut
        env.musicService.play()

        // test
        XCTAssertEqual(database.value(forKey: "currentTrackID") as? MPMediaEntityPersistentID, 1)
    }

    func testCurrentTrackIDLoadedOnStart() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, trackID: 1, userService: userService)
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.currentTrackIndex, 1)
    }

    func testShuffleTracksPersisted() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, trackID: 1, userService: userService)
        env.inject()

        // sut
        env.musicService.shuffle()

        // test
        guard let data = database.value(forKey: "tracks") as? Data else {
            XCTFail("expected Data")
            return
        }
        let trackIDs = NSKeyedUnarchiver.unarchiveObject(with: data) as? [MPMediaEntityPersistentID]
        XCTAssertEqual(trackIDs, [0, 1, 2])
    }

    func testTrackIDsLoadedOnStart() {
        // mocks
        let env = PlayerEnvironment(isPlaying: false, userService: userService)
        env.inject()

        // test
        XCTAssertEqual(env.musicService.state.totalTracks, 3)
    }
}
