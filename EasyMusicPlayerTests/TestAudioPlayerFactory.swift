@testable import EasyMusic
import Foundation

final class TestAudioPlayerFactory: AudioPlayerFactoring {
    let isPlaying: Bool
    let didPrepare: Bool
    let didPlay: Bool
    let currentTime: TimeInterval
    let duration: TimeInterval
    var audioPlayer: MockAudioPlayer?

    init(isPlaying: Bool, didPrepare: Bool, didPlay: Bool, currentTime: TimeInterval, duration: TimeInterval) {
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
