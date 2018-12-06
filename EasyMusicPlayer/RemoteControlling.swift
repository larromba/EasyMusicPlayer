import Foundation
import MediaPlayer

// sourcery: name = RemoteCommandCenter
protocol RemoteControlling: Mockable {
    // sourcery: value = .mock
    var togglePlayPauseCommand: MPRemoteCommand { get }
    // sourcery: value = .mock
    var pauseCommand: MPRemoteCommand { get }
    // sourcery: value = .mock
    var playCommand: MPRemoteCommand { get }
    // sourcery: value = .mock
    var stopCommand: MPRemoteCommand { get }
    // sourcery: value = .mock
    var previousTrackCommand: MPRemoteCommand { get }
    // sourcery: value = .mock
    var nextTrackCommand: MPRemoteCommand { get }
    // sourcery: value = .mockSeek(2)
    var seekForwardCommand: MPRemoteCommand { get }
    // sourcery: value = .mockSeek(2)
    var seekBackwardCommand: MPRemoteCommand { get }
    // sourcery: value = .mockPlayback(MockMediaItem.playbackDuration / 2)
    var changePlaybackPositionCommand: MPChangePlaybackPositionCommand { get }
}
extension MPRemoteCommandCenter: RemoteControlling {}

@objc
protocol ChangePlaybackPositionCommandEvent {
    var positionTime: TimeInterval { get }
}
extension MPChangePlaybackPositionCommandEvent: ChangePlaybackPositionCommandEvent {}

@objc
protocol SeekCommandEvent {
    var type: MPSeekCommandEventType { get }
}
extension MPSeekCommandEvent: SeekCommandEvent {}
