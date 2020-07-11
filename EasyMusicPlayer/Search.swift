import Foundation
import MediaPlayer

protocol Searchable {
    func all(_ completion: @escaping ([MPMediaItem]) -> Void)
    func find(_ text: String, completion: @escaping ([MPMediaItem]) -> Void)
}

final class Search: Searchable {
    private let authorization: Authorization
    private let mediaQuery: MediaQueryable.Type
    private let operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(authorization: Authorization, mediaQuery: MediaQueryable.Type) {
        self.authorization = authorization
        self.mediaQuery = mediaQuery
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
                completion(self.mediaQuery.songs().items ?? [])
            }
        }
    }

    func find(_ text: String, completion: @escaping ([MPMediaItem]) -> Void) {
        guard authorization.isAuthorized else {
            completion([])
            return
        }
        operationQueue.cancelAllOperations()
        operationQueue.addOperation { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                completion(self.mediaQuery.search(text))
            }
        }
    }
}
