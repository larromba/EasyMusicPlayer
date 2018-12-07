import UIKit

// sourcery: name = AlertController
protocol AlertControlling: Mockable {
    func showAlert(_ alert: Alert)
}

final class AlertController: AlertControlling {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func showAlert(_ alert: Alert) {
        let alertController = UIAlertController(title: alert.title, message: alert.text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alert.buttonTitle, style: .default))
        viewController.present(alertController, animated: true, completion: nil)
    }
}
