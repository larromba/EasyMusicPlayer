import MediaPlayer
import UIKit

// sourcery: name = PlayerViewController
protocol PlayerViewControlling: AnyObject, Mockable {
    var viewState: PlayerViewStating? { get set }
    var scrubberViewController: ScrubberViewControlling { get }
    var infoViewController: InfoViewControlling { get }
    var controlsViewController: ControlsViewControlling { get }
}

final class PlayerViewController: UIViewController, PlayerViewControlling {
    @IBOutlet private(set) weak var appVersionLabel: UILabel!

    var viewState: PlayerViewStating? {
        didSet { _ = viewState.map(bind) }
    }
    var scrubberViewController: ScrubberViewControlling {
        return childViewControllers.first { $0 is ScrubberViewControlling } as! ScrubberViewControlling
    }
    var infoViewController: InfoViewControlling {
        return childViewControllers.first { $0 is InfoViewController } as! InfoViewControlling
    }
    var controlsViewController: ControlsViewControlling {
        return childViewControllers.first { $0 is ControlsViewController } as! ControlsViewControlling
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewState.map(bind)
    }

    // MARK: - private

    private func bind(_ viewState: PlayerViewStating) {
        guard isViewLoaded else { return }
        appVersionLabel.text = viewState.appVersion
    }
}
