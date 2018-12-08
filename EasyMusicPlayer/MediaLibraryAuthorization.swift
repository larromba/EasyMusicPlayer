import Foundation
import MediaPlayer

// sourcery: name = MediaLibrary
protocol MediaLibraryAuthorizable: Mockable {
    // sourcery: returnValue = MPMediaLibraryAuthorizationStatus.authorized
    static func authorizationStatus() -> MPMediaLibraryAuthorizationStatus
    static func requestAuthorization(_ handler: @escaping (MPMediaLibraryAuthorizationStatus) -> Void)
}
extension MPMediaLibrary: MediaLibraryAuthorizable {}
