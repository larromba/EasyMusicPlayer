import Logging
import UIKit

// sourcery: name = AlertController
protocol AlertControlling: Mockable {
    func showAlert(_ alert: Alert)
}

final class AlertController: AlertControlling {
    private let presenter: Presentable

    init(presenter: Presentable) {
        self.presenter = presenter
    }

    func showAlert(_ alert: Alert) {
        guard !presenter.isPresenting else {
            logWarning("can't present alert as already presenting something")
            return
        }
        let alertController = UIAlertController(title: alert.title, message: alert.text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: alert.buttonTitle, style: .default))
        presenter.present(alertController, animated: true, completion: nil)
    }
}
