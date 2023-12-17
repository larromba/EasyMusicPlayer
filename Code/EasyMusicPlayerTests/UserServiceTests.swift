import AVFoundation
@testable import EasyMusicPlayer
import XCTest

final class UserServiceTests: XCTestCase {
    private var sut: UserService!

    override func setUp() async throws {
        sut = UserService(userDefaults: UserDefaults(suiteName: "test")!)
    }

    override func tearDown() async throws {
        sut = nil
    }

    func test_data_whenSaved_expectCanBeRestored() {
        sut.repeatMode = .one
        XCTAssertEqual(sut.repeatMode, .one)

        sut.currentTrackID = 10
        XCTAssertEqual(sut.currentTrackID, 10)

        sut.trackIDs = [0, 1, 2]
        XCTAssertEqual(sut.trackIDs, [0, 1, 2])
    }
}
