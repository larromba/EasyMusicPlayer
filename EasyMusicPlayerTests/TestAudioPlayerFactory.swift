@testable import EasyMusic
import Foundation

final class TestAudioPlayerFactory: AudioPlayerFactoring {
    var isPlaying: Bool
    var didPrepare: Bool
    var didPlay: Bool
    var currentTime: TimeInterval
    var duration: TimeInterval
    private(set) var audioPlayer: MockAudioPlayer?

    // default state assumes MockAudioPlayer will play & did play audio
    init(isPlaying: Bool = true, didPrepare: Bool = true, didPlay: Bool = true, currentTime: TimeInterval = 0,
         duration: TimeInterval = 60 * 60 * 3) {
        self.isPlaying = isPlaying
        self.didPrepare = didPrepare
        self.didPlay = didPlay
        self.currentTime = currentTime
        self.duration = duration
    }

    func makeAudioPlayer(withContentsOf url: URL) throws -> AudioPlayer {
        let audioPlayer = MockAudioPlayer(contentsOf: url)
        audioPlayer.isPlaying = isPlaying
        audioPlayer.currentTime = currentTime
        audioPlayer.duration = duration
        audioPlayer.actions.set(returnValue: didPrepare, for: MockAudioPlayer.prepareToPlay1.name)
        audioPlayer.actions.set(returnValue: didPlay, for: MockAudioPlayer.play2.name)
        self.audioPlayer = audioPlayer
        return audioPlayer
    }
}
