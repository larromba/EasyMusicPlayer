import AVFoundation
@testable import EasyMusic
import TestExtensions
import XCTest

final class ExtendedAudioPlayerTests: XCTestCase {
    private var assetUrl: URL!
    private var audioPlayer: ExtendedAudioPlayer!

    override func setUp() {
        assetUrl = URL(fileURLWithPath: Bundle.safeMain.infoDictionary!["DummyAudioWithSilencePath"] as! String)
        audioPlayer = try? ExtendedAudioPlayer(contentsOf: assetUrl)
        super.setUp()
    }

    override func tearDown() {
        audioPlayer = nil
        super.tearDown()
    }

    func test_audioPlayer_whenTrackWithEndSilenceLoaded_expectReducedDuration() {
        // precondition
        let avAudioPlayer = try? AVAudioPlayer(contentsOf: assetUrl)
        XCTAssertEqual(avAudioPlayer?.duration ?? 0.0, 16.0, accuracy: 1.0)

        // test
        waitSync()
        XCTAssertEqual(audioPlayer?.duration ?? 0.0, 4.0, accuracy: 1.0)
    }
}
