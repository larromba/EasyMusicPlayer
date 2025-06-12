import Combine
import Foundation
import MediaPlayer

/// @mockable(rx: state = CurrentValueSubject)
protocol MusicPlayable: Sendable {
    var state: AnyPublisher<MusicPlayerState, Never> { get }
    var info: MusicPlayerInformation { get }

    func authorize()
    func play(_ track: MPMediaItem)
    func play(_ position: MusicQueueTrackPosition)
    func pause()
    func togglePlayPause()
    func stop()
    func previous()
    func next()
    func shuffle()
    func toggleRepeatMode()
    func setRepeatMode(_ repeatMode: RepeatMode)
    func setClock(_ timeInterval: TimeInterval, isScrubbing: Bool)
    func startSeeking(_ direction: SeekDirection)
    func stopSeeking()
}
