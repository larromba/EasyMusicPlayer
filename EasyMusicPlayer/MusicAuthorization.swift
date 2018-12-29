import Foundation
import MediaPlayer

final class MusicAuthorization: Authorization {
    private let authorizer: MediaLibraryAuthorizable.Type

    init(authorizer: MediaLibraryAuthorizable.Type) {
        self.authorizer = authorizer
    }

    var isAuthorized: Bool {
        #if DEBUG
        return __isSnapshot ? true : authorizer.authorizationStatus() == .authorized
        #else
        return authorizer.authorizationStatus() == .authorized
        #endif
    }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void)) {
        authorizer.requestAuthorization { status in
            DispatchQueue.main.async(execute: {
                completion(status == .authorized)
            })
        }
    }
}
