@testable import EasyMusic
import MediaPlayer
import XCTest

// swiftlint:disable type_name
final class _CISanityTests: XCTestCase { // underscore so it comes first in CI
    private var player: AVAudioPlayer!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        player = nil
        super.tearDown()
    }

    // v3.0.0
    // discovered ci bugs because the mock audio files waren't playing
    func test_audio_whenURLLoaded_expectPlays() {
        do {
            player = try AVAudioPlayer(contentsOf: DummyAsset.endSilence.url)
            XCTAssertTrue(player.prepareToPlay())
            XCTAssertTrue(player.play())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
