@testable import EasyMusic
import MediaPlayer
import XCTest

final class ExpTests: XCTestCase {
    private var player: AVAudioPlayer!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        player = nil
        super.tearDown()
    }

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
