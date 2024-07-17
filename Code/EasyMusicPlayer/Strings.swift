// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// OK
  internal static let authorizationErrorButton = L10n.tr("Localizable", "authorization error button", fallback: "OK")
  /// In the Settings, please allow us access to your music!
  internal static let authorizationErrorMessage = L10n.tr("Localizable", "authorization error message", fallback: "In the Settings, please allow us access to your music!")
  /// Authorization
  internal static let authorizationErrorTitle = L10n.tr("Localizable", "authorization error title", fallback: "Authorization")
  /// OK
  internal static let finishedAlertButton = L10n.tr("Localizable", "finished alert button", fallback: "OK")
  /// Your playlist finished
  internal static let finishedAlertMsg = L10n.tr("Localizable", "finished alert msg", fallback: "Your playlist finished")
  /// End
  internal static let finishedAlertTitle = L10n.tr("Localizable", "finished alert title", fallback: "End")
  /// OK
  internal static let noMusicErrorButton = L10n.tr("Localizable", "no music error button", fallback: "OK")
  /// You have no music
  internal static let noMusicErrorMsg = L10n.tr("Localizable", "no music error msg", fallback: "You have no music")
  /// Error
  internal static let noMusicErrorTitle = L10n.tr("Localizable", "no music error title", fallback: "Error")
  /// OK
  internal static let noVolumeErrorButton = L10n.tr("Localizable", "no volume error button", fallback: "OK")
  /// Your volume is too low
  internal static let noVolumeErrorMsg = L10n.tr("Localizable", "no volume error msg", fallback: "Your volume is too low")
  /// Error
  internal static let noVolumeErrorTitle = L10n.tr("Localizable", "no volume error title", fallback: "Error")
  /// OK
  internal static let playErrorButton = L10n.tr("Localizable", "play error button", fallback: "OK")
  /// Couldn't play track
  internal static let playErrorMessage = L10n.tr("Localizable", "play error message", fallback: "Couldn't play track")
  /// Error
  internal static let playErrorTitle = L10n.tr("Localizable", "play error title", fallback: "Error")
  /// Nothing Found
  internal static let searchViewEmptyText = L10n.tr("Localizable", "search view empty text", fallback: "Nothing Found")
  /// Search
  internal static let searchViewTitle = L10n.tr("Localizable", "search view title", fallback: "Search")
  /// %@
  internal static func timeFormat(_ p1: Any) -> String {
    return L10n.tr("Localizable", "time format", String(describing: p1), fallback: "%@")
  }
  /// %02d:%02d:%02d
  internal static func timeIntervalFormat(_ p1: Int, _ p2: Int, _ p3: Int) -> String {
    return L10n.tr("Localizable", "time interval format", p1, p2, p3, fallback: "%02d:%02d:%02d")
  }
  /// OK
  internal static let trackErrorButton = L10n.tr("Localizable", "track error button", fallback: "OK")
  /// Couldn't play '%@'
  internal static func trackErrorMsg(_ p1: Any) -> String {
    return L10n.tr("Localizable", "track error msg", String(describing: p1), fallback: "Couldn't play '%@'")
  }
  /// Error
  internal static let trackErrorTitle = L10n.tr("Localizable", "track error title", fallback: "Error")
  /// %i of %i
  internal static func trackPositionFormat(_ p1: Int, _ p2: Int) -> String {
    return L10n.tr("Localizable", "track position format", p1, p2, fallback: "%i of %i")
  }
  /// Unknown Artist
  internal static let unknownArtist = L10n.tr("Localizable", "unknown artist", fallback: "Unknown Artist")
  /// Unknown Title
  internal static let unknownTrack = L10n.tr("Localizable", "unknown track", fallback: "Unknown Title")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
