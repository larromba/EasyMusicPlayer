import Foundation
import MediaPlayer

typealias MusicAuthorizationCompletion = (@Sendable (_ success: Bool) -> Void)

/// @mockable
protocol MusicAuthorizable: Sendable {
    // sourcery: value = true
    var isAuthorized: Bool { get }

    func authorize(_ completion: @escaping MusicAuthorizationCompletion)
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

    func authorize(_ completion: @escaping MusicAuthorizationCompletion) {
        guard !isAuthorized else {
            completion(true)
            return
        }
        MPMediaLibrary.requestAuthorization { status in
            Task { @MainActor in
                completion(status == .authorized)
            }
        }
    }
}
