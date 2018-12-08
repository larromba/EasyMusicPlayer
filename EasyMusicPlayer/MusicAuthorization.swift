import Foundation
import MediaPlayer

final class MusicAuthorization: Authorizable {
    private let authorizer: MusicAuthorizable.Type

    init(authorizer: MusicAuthorizable.Type) {
        self.authorizer = authorizer
    }

    var isAuthorized: Bool {
        if __isSnapshot {
            return true
        } else {
            return authorizer.authorizationStatus() == .authorized
        }
    }

    func authorize(_ completion: @escaping ((_ success: Bool) -> Void)) {
        authorizer.requestAuthorization { status in
            DispatchQueue.main.async(execute: {
                completion(status == .authorized)
            })
        }
    }
}
