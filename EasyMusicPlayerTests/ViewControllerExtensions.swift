@testable import EasyMusic
import Foundation
import UIKit

extension UIViewController {
    static func fromStoryboard<T: UIViewController>() -> T {
        let viewController = UIStoryboard.main()
            .instantiateViewController(withIdentifier: "\(classForCoder())") as! T
        _ = viewController.view
        return viewController
    }
}
