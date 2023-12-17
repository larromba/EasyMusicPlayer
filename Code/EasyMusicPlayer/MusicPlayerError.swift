import Foundation

enum MusicPlayerError: Error {
    case noMusic
    case auth
    case play
    case finished
    case volume
}
