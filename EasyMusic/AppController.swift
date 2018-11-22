import Foundation

protocol AppControlling {
    // 🦄
}

final class AppController: AppControlling {
    private let playerController: PlayerController

    init(playerController: PlayerController) {
        self.playerController = playerController
    }

    //// MARK: - UIViewControllerAnimatedTransitioning
    //
    //extension PlayerController: UIViewControllerTransitioningDelegate {
    //    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    //        return queueAnimation
    //    }
    //
    //    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    //        return queueAnimation
    //    }
    //}
}
