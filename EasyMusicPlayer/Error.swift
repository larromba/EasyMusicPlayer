import Foundation

enum MusicError: Error {
    case decode
    case playerInit
    case noMusic
    case noVolume
    case avError
    case authorization
}

enum NetworkError: Error {
    case noData
    case badJSON
    case systemError(Error)
    case httpErrorCode(Int)
    case badResponse(Error)

    var isCancelled: Bool {
        switch self {
        case .systemError(let error):
            return (error as NSError).code == NSURLErrorCancelled
        default:
            return false
        }
    }
}
