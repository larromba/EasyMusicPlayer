import Foundation

struct Alert {
    let title: String
    let text: String
    let buttonTitle: String
}

extension Alert {
    static var finished = Alert(
        title: L10n.finishedAlertTitle,
        text: L10n.finishedAlertMsg,
        buttonTitle: L10n.finishedAlertButton
    )
    static var noMusic = Alert(
        title: L10n.noMusicErrorTitle,
        text: L10n.noMusicErrorMsg,
        buttonTitle: L10n.noMusicErrorButton
    )
    static var noVolume = Alert(
        title: L10n.noVolumeErrorTitle,
        text: L10n.noVolumeErrorMsg,
        buttonTitle: L10n.noVolumeErrorButton
    )
    static var authError = Alert(
        title: L10n.authorizationErrorTitle,
        text: L10n.authorizationErrorMessage,
        buttonTitle: L10n.authorizationErrorButton
    )
    static var playError = Alert(
        title: L10n.playErrorTitle,
        text: L10n.playErrorMessage,
        buttonTitle: L10n.playErrorButton
    )

    static func trackError(title: String) -> Alert {
        return Alert(
            title: L10n.trackErrorTitle,
            text: L10n.trackErrorMsg(title),
            buttonTitle: L10n.trackErrorButton
        )
    }
}
