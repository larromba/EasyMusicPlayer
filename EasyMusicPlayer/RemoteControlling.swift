import Foundation
import MediaPlayer

protocol RemoteControlling {
    var togglePlayPauseCommand: MPRemoteCommand { get }
    var pauseCommand: MPRemoteCommand { get }
    var playCommand: MPRemoteCommand { get }
    var stopCommand: MPRemoteCommand { get }
    var previousTrackCommand: MPRemoteCommand { get }
    var nextTrackCommand: MPRemoteCommand { get }
    var seekForwardCommand: MPRemoteCommand { get }
    var seekBackwardCommand: MPRemoteCommand { get }
    var changePlaybackPositionCommand: MPChangePlaybackPositionCommand { get }
}
extension MPRemoteCommandCenter: RemoteControlling {}
