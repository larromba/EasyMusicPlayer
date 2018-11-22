import Foundation

extension Bundle {
    static var appName: String {
        guard let bundleName = Bundle.safeMain.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            assertionFailure("bundleName is nil")
            return ""
        }
        return bundleName
    }

    static var appVersion: String {
        guard let bundleVersion = Bundle.safeMain
            .object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String else {
                assertionFailure("appVersion is nil")
                return ""
        }
        return "v\(bundleVersion)"
    }

    static var bundleIdentifier: String {
        guard let bundleIdentifier = Bundle.safeMain
            .object(forInfoDictionaryKey: "CFBundleIdentifier") as? String else {
                return ""
        }
        return bundleIdentifier
    }

    static var safeMain: Bundle {
        return Bundle(identifier: "com.pinkchicken.easymusicplayer")!
    }
}
