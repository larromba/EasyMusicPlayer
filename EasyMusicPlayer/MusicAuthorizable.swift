import Foundation
import MediaPlayer

// sourcery: name = MusicAuthorizer
protocol MusicAuthorizable: Mockable {
    // sourcery: returnValue = MPMediaLibraryAuthorizationStatus.authorized
    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus
    static func requestAuthorization(_ handler: @escaping (MPMediaLibraryAuthorizationStatus) -> Void)
}
extension MPMediaLibrary: MusicAuthorizable {}
