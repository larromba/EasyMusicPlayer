import Foundation
import MediaPlayer

// sourcery: name = ChangePlaybackPositionCommandEvent
@objc
protocol ChangePlaybackPositionCommandEvent: Mockable {
    var positionTime: TimeInterval { get }
}
extension MPChangePlaybackPositionCommandEvent: ChangePlaybackPositionCommandEvent {}

// sourcery: name = ChangeRepeatModeCommandEvent
@objc
protocol ChangeRepeatModeCommandEvent: Mockable {
    var repeatType: MPRepeatType { get }
}
extension MPChangeRepeatModeCommandEvent: ChangeRepeatModeCommandEvent {}

// sourcery: name = SeekCommandEvent
@objc
protocol SeekCommandEvent: Mockable {
    var type: MPSeekCommandEventType { get }
}
extension MPSeekCommandEvent: SeekCommandEvent {}

// sourcery: name = Remote
protocol Remoting: Mockable {
    var state: RemoteState { get set }
    var togglePlayPause: (() -> Void)? { get set }
    var pause: (() -> Void)? { get set }
    var play: (() -> Void)? { get set }
    var stop: (() -> Void)? { get set }
    var prev: (() -> Void)? { get set }
    var next: (() -> Void)? { get set }
    var seekBackward: ((SeekCommandEvent) -> Void)? { get set }
    var seekForward: ((SeekCommandEvent) -> Void)? { get set }
    var changePlayback: ((ChangePlaybackPositionCommandEvent) -> Void)? { get set }
    var repeatMode: ((ChangeRepeatModeCommandEvent) -> Void)? { get set }
}

final class Remote: Remoting {
    var state: RemoteState {
        get {
            return RemoteState(
                isTogglePlayPauseEnabled: remote.togglePlayPauseCommand.isEnabled,
                isPauseEnabled: remote.pauseCommand.isEnabled,
                isPlayEnabled: remote.playCommand.isEnabled,
                isStopEnabled: remote.stopCommand.isEnabled,
                isPreviousEnabled: remote.previousTrackCommand.isEnabled,
                isNextEnabled: remote.nextTrackCommand.isEnabled,
                isSeekForwardEnabled: remote.seekForwardCommand.isEnabled,
                isSeekBackwardEnabled: remote.seekBackwardCommand.isEnabled,
                isChangePlaybackEnabled: remote.changePlaybackPositionCommand.isEnabled,
                isRepeatModeEnabled: remote.changeRepeatModeCommand.isEnabled,
                repeatState: remote.changeRepeatModeCommand.currentRepeatType.repeatState
            )
        }
        set {
            remote.togglePlayPauseCommand.isEnabled = newValue.isTogglePlayPauseEnabled
            remote.pauseCommand.isEnabled = newValue.isPauseEnabled
            remote.playCommand.isEnabled = newValue.isPlayEnabled
            remote.stopCommand.isEnabled = newValue.isStopEnabled
            remote.previousTrackCommand.isEnabled = newValue.isPreviousEnabled
            remote.nextTrackCommand.isEnabled = newValue.isNextEnabled
            remote.seekForwardCommand.isEnabled = newValue.isSeekForwardEnabled
            remote.seekBackwardCommand.isEnabled = newValue.isSeekBackwardEnabled
            remote.changePlaybackPositionCommand.isEnabled = newValue.isChangePlaybackEnabled
            remote.changeRepeatModeCommand.isEnabled = newValue.isRepeatModeEnabled
            remote.changeRepeatModeCommand.currentRepeatType = newValue.repeatState.remoteRepeatType
        }
    }
    var togglePlayPause: (() -> Void)?
    var pause: (() -> Void)?
    var play: (() -> Void)?
    var stop: (() -> Void)?
    var prev: (() -> Void)?
    var next: (() -> Void)?
    var seekBackward: ((SeekCommandEvent) -> Void)?
    var seekForward: ((SeekCommandEvent) -> Void)?
    var changePlayback: ((ChangePlaybackPositionCommandEvent) -> Void)?
    var repeatMode: ((ChangeRepeatModeCommandEvent) -> Void)?

    private let remote: MPRemoteCommandCenter

    init(remote: MPRemoteCommandCenter = .shared()) {
        self.remote = remote
        setupRemote()
    }

    deinit {
        remote.togglePlayPauseCommand.removeTarget(self)
        remote.pauseCommand.removeTarget(self)
        remote.playCommand.removeTarget(self)
        remote.previousTrackCommand.removeTarget(self)
        remote.nextTrackCommand.removeTarget(self)
        remote.seekForwardCommand.removeTarget(self)
        remote.seekBackwardCommand.removeTarget(self)
        remote.changePlaybackPositionCommand.removeTarget(self)
        remote.changeRepeatModeCommand.removeTarget(self)
    }

    // MARK: - private

    private func setupRemote() {
        remote.togglePlayPauseCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.togglePlayPause?()
            return .success
        }
        remote.pauseCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.pause?()
            return .success
        }
        remote.playCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.play?()
            return .success
        }
        remote.stopCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.stop?()
            return .success
        }
        remote.previousTrackCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.prev?()
            return .success
        }
        remote.nextTrackCommand.addTarget { _ -> MPRemoteCommandHandlerStatus in
            self.next?()
            return .success
        }
        remote.seekBackwardCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let event = event as? MPSeekCommandEvent else { return .commandFailed }
            self.seekBackward?(event)
            return .success
        }
        remote.seekForwardCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let event = event as? MPSeekCommandEvent else { return .commandFailed }
            self.seekForward?(event)
            return .success
        }
        remote.changePlaybackPositionCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let event = event as? MPChangePlaybackPositionCommandEvent else { return .commandFailed }
            self.changePlayback?(event)
            return .success
        }
        remote.changeRepeatModeCommand.addTarget { event -> MPRemoteCommandHandlerStatus in
            guard let event = event as? MPChangeRepeatModeCommandEvent else { return .commandFailed }
            self.repeatMode?(event)
            return .success
        }
    }
}
