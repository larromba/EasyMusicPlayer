import Foundation
import MediaPlayer

protocol UserServicing: AnyObject {
    var repeatState: RepeatState? { get set }
    var currentTrackID: MPMediaEntityPersistentID? { get set }
    var trackIDs: [MPMediaEntityPersistentID]? { get set }
}

final class UserService: UserServicing {
    private enum Key: String, Keyable {
        case repeatState
        case tracks
        case currentTrackID
    }

    private let dataManager: DataManaging

    init(dataManager: DataManaging) {
        self.dataManager = dataManager
    }

    var repeatState: RepeatState? {
        get {
            guard let rawValue: String = dataManager.load(key: Key.repeatState) else {
                return nil
            }
            return RepeatState(rawValue: rawValue)
        }
        set {
            dataManager.save(newValue?.rawValue, key: Key.repeatState)
        }
    }

    var currentTrackID: MPMediaEntityPersistentID? {
        get {
            return dataManager.load(key: Key.currentTrackID)
        }
        set {
            dataManager.save(newValue, key: Key.currentTrackID)
        }
    }

    var trackIDs: [MPMediaEntityPersistentID]? {
        get {
            guard let data: Data = dataManager.load(key: Key.tracks) else {
                return nil
            }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [MPMediaEntityPersistentID]
        }
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue ?? [])
            dataManager.save(data, key: Key.tracks)
        }
    }
}
