import UIKit

protocol KeyboardNotificationDelegate: AnyObject {
    func keyboardWithShow(height: CGFloat)
    func keyboardWillHide()
}

final class KeyboardNotification {
    weak var delegate: KeyboardNotificationDelegate?

    func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)),
                                               name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)),
                                               name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    func tearDown() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    // MARK: - private

    @objc
    private func keyboardWillShow(_ notification: Notification) {
        guard let value = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        delegate?.keyboardWithShow(height: value.cgRectValue.height)
    }

    @objc
    private func keyboardWillHide(_ notification: Notification) {
        delegate?.keyboardWillHide()
    }
}
