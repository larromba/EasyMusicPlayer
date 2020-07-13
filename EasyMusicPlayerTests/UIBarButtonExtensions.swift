import UIKit

extension UIBarButtonItem {
    func fire() -> Bool {
        guard let target = target, let action = action else {
            assertionFailure("expected target and action")
            return false
        }
        return UIApplication.shared.sendAction(action, to: target, from: self, for: nil)
    }
}
