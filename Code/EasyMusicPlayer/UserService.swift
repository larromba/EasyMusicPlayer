import Foundation
import MediaPlayer

/// @mockable
protocol UserServicing: AnyObject {
    var repeatMode: RepeatMode? { get set }
    var currentTrackID: MPMediaEntityPersistentID? { get set }
    var trackIDs: [MPMediaEntityPersistentID]? { get set }
}

final class UserService: UserServicing {
    var repeatMode: RepeatMode? {
        get { 
            guard let rawValue = userDefaults.string(forKey: Key.repeatMode.rawValue) else { return nil }
            return RepeatMode(rawValue: rawValue)
        }
        set {
            userDefaults.set(newValue?.rawValue, forKey: Key.repeatMode.rawValue)
        }
    }
    var currentTrackID: MPMediaEntityPersistentID? {
        get {
            userDefaults.value(forKey: Key.currentTrackID.rawValue) as? MPMediaEntityPersistentID
        }
        set {
            userDefaults.set(newValue, forKey: Key.currentTrackID.rawValue)
        }
    }
    var trackIDs: [MPMediaEntityPersistentID]? {
        get {
            userDefaults.array(forKey: Key.tracks.rawValue) as? [MPMediaEntityPersistentID]
        }
        set {
            userDefaults.set(newValue, forKey: Key.tracks.rawValue)
        }
    }

    private enum Key: String {
        case repeatMode
        case tracks
        case currentTrackID
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
}
