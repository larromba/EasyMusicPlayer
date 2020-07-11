import Logging
import UIKit

// sourcery: name = AppRouter
protocol AppRouting: Mockable {
    // 🦄
}

final class AppRouter: AppRouting {
    private let playerCoordinator: PlayerCoordinating
    private let searchCoordinator: SearchCoordinating

    init(playerCoordinator: PlayerCoordinating, searchCoordinator: SearchCoordinating) {
        self.playerCoordinator = playerCoordinator
        self.searchCoordinator = searchCoordinator
        playerCoordinator.setDelegate(self)
        searchCoordinator.setDelegate(self)
    }

    // MARK: - private

    private func handleSegue(_ segue: UIStoryboardSegue, sender: Any?) {
        guard let navigationController = segue.destination as? UINavigationController else { return }
        if let viewController = navigationController.viewControllers.first as? SearchViewControlling {
            searchCoordinator.setNavigationController(navigationController)
            searchCoordinator.setViewController(viewController)
            searchCoordinator.start()
        } else {
            logWarning("unhandled viewcontroller: \(String(describing: navigationController.viewControllers.first))")
        }
    }
}

// MARK: - PlayerCoordinatorDelegate

extension AppRouter: PlayerCoordinatorDelegate {
    func coordinator(_ coordinator: PlayerCoordinating, prepareForSegue segue: UIStoryboardSegue, sender: Any?) {
        handleSegue(segue, sender: sender)
    }
}

// MARK: - SearchCoordinatorDelegate

extension AppRouter: SearchCoordinatorDelegate {
    func coordinator(_ coordinator: SearchCoordinating, didFinishWithItem track: Track?) {
        guard let track = track else { return }
        playerCoordinator.play(track)
    }
}
