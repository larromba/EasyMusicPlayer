import Foundation

protocol AppControlling {
    // 🦄
}

final class AppController: AppControlling {
    private let playerController: PlayerController

    init(playerController: PlayerController) {
        self.playerController = playerController
    }
}
