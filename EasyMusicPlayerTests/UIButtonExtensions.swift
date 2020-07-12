import UIKit

extension UIButton {
    @discardableResult
    func fire() -> Bool {
        guard isEnabled else { return false }
        sendActions(for: .touchUpInside)
        return true
    }
}
