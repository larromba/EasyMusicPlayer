@testable import EasyMusic
import Foundation
import UIKit

extension UIViewController {
    static func fromStoryboard<T: UIViewController>() -> T {
        let viewController = UIStoryboard.player.instantiateViewController(withIdentifier: "\(self)") as! T
        _ = viewController.view
        return viewController
    }
}
