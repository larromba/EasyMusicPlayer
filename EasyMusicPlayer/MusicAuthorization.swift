import Foundation
import MediaPlayer

final class MusicAuthorization: Authorization {
    private let authorizer: MediaLibraryAuthorizable.Type

    init(authorizer: MediaLibraryAuthorizable.Type) {
        self.authorizer = authorizer
    }

    var isAuthorized: Bool {
        #if DEBUG
        if __isSnapshot {
            return true
        }
        #endif
        return authorizer.authorizationStatus() == .authorized
    }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void)) {
        guard !isAuthorized else {
            completion(true)
            return
        }
        authorizer.requestAuthorization { status in
            DispatchQueue.main.async(execute: {
                completion(status == .authorized)
            })
        }
    }
}
