import Foundation
import MediaPlayer

/// @mockable
protocol MusicAuthorizable {
    // sourcery: value = true
    var isAuthorized: Bool { get }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void))
}

final class MusicAuthorization: MusicAuthorizable {
    var isAuthorized: Bool {
        #if DEBUG
        if __isSnapshot {
            // prevents dialogue appearing when trying to make snapshots
            return true
        }
        #endif
        return MPMediaLibrary.authorizationStatus() == .authorized
    }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void)) {
        guard !isAuthorized else {
            completion(true)
            return
        }
        MPMediaLibrary.requestAuthorization { status in
            DispatchQueue.main.async {
                completion(status == .authorized)
            }
        }
    }
}
