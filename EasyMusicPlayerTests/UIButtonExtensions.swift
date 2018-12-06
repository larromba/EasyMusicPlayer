import UIKit

extension UIButton {
    func tap() {
        sendActions(for: .touchUpInside)
    }
}
