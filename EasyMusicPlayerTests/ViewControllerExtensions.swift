@testable import EasyMusic
import Foundation
import UIKit

extension ControlsViewController {
    static var fromStoryboard: ControlsViewController {
        let viewController = UIStoryboard.main()
            .instantiateViewController(withIdentifier: "ControlsViewController") as! ControlsViewController
        _ = viewController.view
        return viewController
    }
}

extension ScrubberViewController {
    static var fromStoryboard: ScrubberViewController {
        let viewController = UIStoryboard.main()
            .instantiateViewController(withIdentifier: "ScrubberViewController") as! ScrubberViewController
        _ = viewController.view
        return viewController
    }
}
