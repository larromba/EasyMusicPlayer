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

    // MARK: - isLofiEnabled

    @Test
    func isLofiEnabled_whenSet_expectCanBeFetched() {
        sut.isLofiEnabled = true
        #expect(sut.isLofiEnabled)
    }

    // MARK: - isDistortionEnabled

    @Test
    func isDistortionEnabled_whenSet_expectCanBeFetched() {
        sut.isDistortionEnabled = true
        #expect(sut.isDistortionEnabled)
    }
}
