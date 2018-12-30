import UIKit

protocol Presentable {
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?)
}
extension UIViewController: Presentable {}
