import AVFoundation
import Foundation

// sourcery: name = AudioPlayerFactory
protocol AudioPlayerFactoring: Mockable {
    func makeAudioPlayer(withContentsOf url: URL) throws -> AudioPlayer
}

final class AudioPlayerFactory: AudioPlayerFactoring {
    func makeAudioPlayer(withContentsOf url: URL) throws -> AudioPlayer {
        return try ExtendedAudioPlayer(contentsOf: url)
    }
}
