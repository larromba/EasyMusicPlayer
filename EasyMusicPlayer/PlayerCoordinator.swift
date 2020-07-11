import UIKit

// sourcery: name = PlayerCoordinator
protocol PlayerCoordinating: Mockable {
    func setDelegate(_ delegate: PlayerCoordinatorDelegate)
    func play(_ track: Track)
}

protocol PlayerCoordinatorDelegate: AnyObject {
    func coordinator(_ coordinator: PlayerCoordinating, prepareForSegue segue: UIStoryboardSegue, sender: Any?)
}

final class PlayerCoordinator: PlayerCoordinating {
    private let playerController: PlayerControlling
    private let alertController: AlertControlling
    private weak var delegate: PlayerCoordinatorDelegate?

    init(playerController: PlayerControlling, alertController: AlertControlling) {
        self.playerController = playerController
        self.alertController = alertController
        playerController.setDelegate(self)
    }

    func setDelegate(_ delegate: PlayerCoordinatorDelegate) {
        self.delegate = delegate
    }

    func play(_ track: Track) {
        playerController.play(track)
    }
}

// MARK: - PlayerControllerDelegate

extension PlayerCoordinator: PlayerControllerDelegate {
    func controller(_ controller: PlayerControlling, showAlert alert: Alert) {
        alertController.showAlert(alert)
    }

    func controller(_ controller: PlayerControlling, prepareForSegue segue: UIStoryboardSegue, sender: Any?) {
        delegate?.coordinator(self, prepareForSegue: segue, sender: sender)
    }
}
