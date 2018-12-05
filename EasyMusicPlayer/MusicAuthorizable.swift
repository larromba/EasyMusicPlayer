import Foundation
import MediaPlayer

protocol MusicAuthorizable {
    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus
    static func requestAuthorization(_ handler: @escaping (MPMediaLibraryAuthorizationStatus) -> Void)
}
extension MPMediaLibrary: MusicAuthorizable {}
