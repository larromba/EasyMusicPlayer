import AVFoundation
@testable import EasyMusicPlayer
import Testing

struct UserServiceTests {
    private let sut = UserService(userDefaults: UserDefaults(suiteName: "test")!)

    // MARK: - repeatMode

    @Test
    func repeatMode_whenSet_expectCanBeFetched() {
        sut.repeatMode = .one
        #expect(sut.repeatMode == .one)
    }

    // MARK: - currentTrackID

    @Test
    func currentTrackID_whenSet_expectCanBeFetched() {
        sut.currentTrackID = 10
        #expect(sut.currentTrackID == 10)
    }

    // MARK: - trackIDs

    @Test
    func trackIDs_whenSet_expectCanBeFetched() {
        sut.trackIDs = [0, 1, 2]
        #expect(sut.trackIDs == [0, 1, 2])
    }
}
