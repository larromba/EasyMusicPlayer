import SwiftUI

@main
struct EasyMusicPlayerApp: App {
    private let userService = UserService()

    init() {
        #if DEBUG
        if __isSnapshot {
            userService.isDistortionEnabled = true
            userService.isLofiEnabled = true
            userService.currentTrackID = nil
            userService.trackIDs = nil
            userService.repeatMode = .all
        }
        #endif
    }

    var body: some Scene {
        WindowGroup {
            PlayerView()
        }
    }
}
