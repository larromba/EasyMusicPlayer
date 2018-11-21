import UIKit

protocol AlertControlling {
    func showAlert(_ alert: Alert)
}

final class AlertController: AlertControlling {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showAlert(_ alert: Alert) {
        // TODO: UIAlertController.withTitle
        let alertViewController = UIAlertController.withTitle(alert.title, message: alert.text,
                                                              buttonTitle: alert.buttonTitle)
        viewController.present(alertViewController, animated: true, completion: nil)
    }
}
