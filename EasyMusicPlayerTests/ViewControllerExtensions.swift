@testable import EasyMusic
import Foundation
import UIKit

// TODO: refactor

extension UIViewController {
    static func fromStoryboard<T: UIViewController>() -> T {
        let viewController = UIStoryboard.main()
            .instantiateViewController(withIdentifier: "\(classForCoder())") as! T
        _ = viewController.view
        return viewController
    }

//    static var fromStoryboard: UIViewController {
//        let viewController = UIStoryboard.main()
//            .instantiateViewController(withIdentifier: "\(classForCoder())") as! T
//        _ = viewController.view
//        return viewController
//    }
}

//extension ControlsViewController {
//    static var fromStoryboard: ControlsViewController {
//        let viewController = UIStoryboard.main()
//            .instantiateViewController(withIdentifier: "ControlsViewController") as! ControlsViewController
//        _ = viewController.view
//        return viewController
//    }
//}
//
//extension ScrubberViewController {
//    static var fromStoryboard: ScrubberViewController {
//        let viewController = UIStoryboard.main()
//            .instantiateViewController(withIdentifier: "ScrubberViewController") as! ScrubberViewController
//        _ = viewController.view
//        return viewController
//    }
//}
//
//extension InfoViewController {
//    static var fromStoryboard: InfoViewController {
//        let viewController = UIStoryboard.main()
//            .instantiateViewController(withIdentifier: "InfoViewController") as! InfoViewController
//        _ = viewController.view
//        return viewController
//    }
//}
