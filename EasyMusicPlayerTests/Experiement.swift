@testable import EasyMusic
import MediaPlayer
import XCTest

final class ExpTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func test_experiement() {
        do {
            let player = try AVAudioPlayer(contentsOf: DummyAsset.endSilence.url)
            XCTAssertTrue(player.prepareToPlay())
            XCTAssertTrue(player.play())
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
