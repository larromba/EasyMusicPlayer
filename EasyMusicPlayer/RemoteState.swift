import Foundation

struct RemoteState {
    var isTogglePlayPauseEnabled: Bool
    var isPauseEnabled: Bool
    var isPlayEnabled: Bool
    var isStopEnabled: Bool
    var isPreviousEnabled: Bool
    var isNextEnabled: Bool
    var isSeekForwardEnabled: Bool
    var isSeekBackwardEnabled: Bool
    var isChangePlaybackEnabled: Bool
    var isRepeatModeEnabled: Bool
    var repeatState: RepeatState
}
