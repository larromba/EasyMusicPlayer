import Foundation

// swiftlint:disable identifier_name
var __isSnapshot: Bool {
    return UserDefaults.standard.string(forKey: "FASTLANE_SNAPSHOT") != nil
}
