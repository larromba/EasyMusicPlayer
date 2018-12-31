@testable import EasyMusic
import Foundation
import MediaPlayer

final class TestUserDefaults: UserDefaultable {
    var repeatState: RepeatState?
    var trackIDs: [MPMediaEntityPersistentID]?
    var currentTrackID: MPMediaEntityPersistentID?

    func object(forKey defaultName: String) -> Any? {
        switch defaultName {
        case "repeatState":
            return repeatState
        case "tracks":
            guard let trackIDs = trackIDs else { return nil }
            return NSKeyedArchiver.archivedData(withRootObject: trackIDs)
        case "currentTrackID": return currentTrackID
        default:
            assertionFailure("unhandled key: \(defaultName)")
            return nil
        }
    }

    func set(_ value: Any?, forKey defaultName: String) {}
}
