import Foundation
import MediaPlayer

protocol UserServicing: AnyObject, Sendable {
    var repeatMode: RepeatMode? { get set }
    var currentTrackID: MPMediaEntityPersistentID? { get set }
    var trackIDs: [MPMediaEntityPersistentID]? { get set }
    var isLofiEnabled: Bool { get set }
    var isDistortionEnabled: Bool { get set }
}

final class UserService: UserServicing, @unchecked Sendable {
    private let userDefaults: UserDefaults
    private let queue = DispatchQueue(
        label: "UserService.userDefaultsQueue",
        attributes: .concurrent
    )

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    var repeatMode: RepeatMode? {
        get {
            queue.sync {
                guard let rawValue = userDefaults.string(forKey: Key.repeatMode.rawValue) else {
                    return nil
                }
                return RepeatMode(rawValue: rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.userDefaults.set(newValue?.rawValue, forKey: Key.repeatMode.rawValue)
            }
        }
    }

    var currentTrackID: MPMediaEntityPersistentID? {
        get {
            queue.sync {
                userDefaults.value(forKey: Key.currentTrackID.rawValue) as? MPMediaEntityPersistentID
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.userDefaults.set(newValue, forKey: Key.currentTrackID.rawValue)
            }
        }
    }

    var trackIDs: [MPMediaEntityPersistentID]? {
        get {
            queue.sync {
                userDefaults.array(forKey: Key.tracks.rawValue) as? [MPMediaEntityPersistentID]
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.userDefaults.set(newValue, forKey: Key.tracks.rawValue)
            }
        }
    }

    var isLofiEnabled: Bool {
        get {
            queue.sync {
                userDefaults.bool(forKey: Key.lofi.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.userDefaults.set(newValue, forKey: Key.lofi.rawValue)
            }
        }
    }

    var isDistortionEnabled: Bool {
        get {
            queue.sync {
                userDefaults.bool(forKey: Key.distortion.rawValue)
            }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                self?.userDefaults.set(newValue, forKey: Key.distortion.rawValue)
            }
        }
    }
}

private extension UserService {
    enum Key: String {
        case repeatMode
        case tracks
        case currentTrackID
        case lofi
        case distortion
    }
}
