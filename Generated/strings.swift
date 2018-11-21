// swiftlint:disable all
// Generated using SwiftGen, by O.Halligon — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command
// swiftlint:disable file_length

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name
internal enum L10n {
  /// OK
  internal static let accountsErrorButton = L10n.tr("Localizable", "accounts error button")
  /// Please check your social accounts are correctly setup and try again
  internal static let accountsErrorMsg = L10n.tr("Localizable", "accounts error msg")
  /// Accounts
  internal static let accountsErrorTitle = L10n.tr("Localizable", "accounts error title")
  /// OK
  internal static let authorizationErrorButton = L10n.tr("Localizable", "authorization error button")
  /// In the Settings, please allow us access to your music!
  internal static let authorizationErrorMessage = L10n.tr("Localizable", "authorization error message")
  /// Authorization
  internal static let authorizationErrorTitle = L10n.tr("Localizable", "authorization error title")
  /// OK
  internal static let finishedAlertButton = L10n.tr("Localizable", "finished alert button")
  /// Your playlist finished
  internal static let finishedAlertMsg = L10n.tr("Localizable", "finished alert msg")
  /// End
  internal static let finishedAlertTitle = L10n.tr("Localizable", "finished alert title")
  /// OK
  internal static let noMusicErrorButton = L10n.tr("Localizable", "no music error button")
  /// You have no music
  internal static let noMusicErrorMsg = L10n.tr("Localizable", "no music error msg")
  /// Error
  internal static let noMusicErrorTitle = L10n.tr("Localizable", "no music error title")
  /// OK
  internal static let noVolumeErrorButton = L10n.tr("Localizable", "no volume error button")
  /// Your volume is too low
  internal static let noVolumeErrorMsg = L10n.tr("Localizable", "no volume error msg")
  /// Error
  internal static let noVolumeErrorTitle = L10n.tr("Localizable", "no volume error title")
  /// %@ - %@ (via %@)
  internal static func shareFormat(_ p1: String, _ p2: String, _ p3: String) -> String {
    return L10n.tr("Localizable", "share format", p1, p2, p3)
  }
  /// Cancel
  internal static let shareOptionCancel = L10n.tr("Localizable", "share option cancel")
  /// Facebook
  internal static let shareOptionFacebook = L10n.tr("Localizable", "share option facebook")
  /// Twitter
  internal static let shareOptionTwitter = L10n.tr("Localizable", "share option twitter")
  /// Where do you want to share this tune?
  internal static let shareSheetDesc = L10n.tr("Localizable", "share sheet desc")
  /// Share
  internal static let shareSheetTitle = L10n.tr("Localizable", "share sheet title")
  /// %@
  internal static func timeFormat(_ p1: String) -> String {
    return L10n.tr("Localizable", "time format", p1)
  }
  /// %02d:%02d:%02d
  internal static func timeIntervalFormat(_ p1: Int, _ p2: Int, _ p3: Int) -> String {
    return L10n.tr("Localizable", "time interval format", p1, p2, p3)
  }
  /// OK
  internal static let trackErrorButton = L10n.tr("Localizable", "track error button")
  /// Couldn't play '%@'
  internal static func trackErrorMsg(_ p1: String) -> String {
    return L10n.tr("Localizable", "track error msg", p1)
  }
  /// Error
  internal static let trackErrorTitle = L10n.tr("Localizable", "track error title")
  /// %i of %i
  internal static func trackPositionFormat(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "track position format", p1, p2)
  }
  /// Unknown Artist
  internal static let unknownArtist = L10n.tr("Localizable", "unknown artist")
  /// Unknown Title
  internal static let unknownTrack = L10n.tr("Localizable", "unknown track")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
    let format = NSLocalizedString(key, tableName: table, bundle: Bundle(for: BundleToken.self), comment: "")
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

private final class BundleToken {}
