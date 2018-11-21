import Foundation

enum MusicError: Error {
    case decode
    case playerInit
    case noMusic
    case noVolume
    case avError
    case authorization
}
