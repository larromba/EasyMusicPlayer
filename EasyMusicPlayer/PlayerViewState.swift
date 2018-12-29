import Foundation

protocol PlayerViewStating {
    var appVersion: String { get }
}

struct PlayerViewState: PlayerViewStating {
    let appVersion: String
}
