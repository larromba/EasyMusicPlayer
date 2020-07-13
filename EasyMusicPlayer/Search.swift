import Foundation
import Logging
import MediaPlayer

protocol Searchable {
    func all(_ completion: @escaping ([MPMediaItem]) -> Void)
    func find(_ text: String, completion: @escaping ([MPMediaItem]) -> Void)
}

final class Search: Searchable {
    private let authorization: Authorization
    private let trackManager: TrackManaging
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(authorization: Authorization, trackManager: TrackManaging) {
        self.authorization = authorization
        self.trackManager = trackManager
    }

    func all(_ completion: @escaping ([MPMediaItem]) -> Void) {
        guard authorization.isAuthorized else {
            completion([])
            return
        }
        operationQueue.cancelAllOperations()
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                log("resetting tracks")
                completion(self.trackManager.tracks)
            }
        }
    }

    func find(_ text: String, completion: @escaping ([MPMediaItem]) -> Void) {
        guard authorization.isAuthorized else {
            completion([])
            return
        }
        operationQueue.cancelAllOperations()
        operationQueue.addOperation(SearchOperation(tracks: trackManager.tracks, text: text, completion: completion))
    }
}
