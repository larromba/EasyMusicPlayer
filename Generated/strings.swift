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
  /// OK
  internal static let playErrorButton = L10n.tr("Localizable", "play error button")
  /// Couldn't play track
  internal static let playErrorMessage = L10n.tr("Localizable", "play error message")
  /// Error
  internal static let playErrorTitle = L10n.tr("Localizable", "play error title")
  /// Nothing Found
  internal static let searchViewEmptyText = L10n.tr("Localizable", "search view empty text")
  /// Search
  internal static let searchViewTitle = L10n.tr("Localizable", "search view title")
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
