import Foundation

// sourcery: name = AppController
protocol AppControlling: Mockable {
    // 🦄
}

final class AppController: AppControlling {
    private let playerController: PlayerControlling

    init(playerController: PlayerControlling) {
        self.playerController = playerController
    }
}
