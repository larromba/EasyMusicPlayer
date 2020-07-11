import Logging
import UIKit

// sourcery: name = AlertController
protocol AlertControlling: Mockable {
    func showAlert(_ alert: Alert)
}

final class AlertController: AlertControlling {
    private let presenter: Presentable
    private weak var alertController: UIAlertController?

    init(presenter: Presentable) {
        self.presenter = presenter
    }

    func showAlert(_ alert: Alert) {
        guard alertController == nil else {
            logWarning("already showing an alert")
            return
        }
        let alertController = UIAlertController(title: alert.title, message: alert.text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alert.buttonTitle, style: .default))
        presenter.present(alertController, animated: true, completion: nil)
        self.alertController = alertController
    }
}
