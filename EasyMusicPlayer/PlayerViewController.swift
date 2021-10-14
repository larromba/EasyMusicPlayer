import MediaPlayer
import UIKit

// sourcery: name = PlayerViewController
protocol PlayerViewControlling: Mockable {
    var viewState: PlayerViewStating? { get set }
    var scrubberViewController: ScrubberViewControlling { get }
    var infoViewController: InfoViewControlling { get }
    var controlsViewController: ControlsViewControlling { get }

    func setDelegate(_ delegate: PlayerViewControllerDelegate)
    func showSearch()
}

protocol PlayerViewControllerDelegate: AnyObject {
    func viewController(_ viewController: PlayerViewControlling, prepareForSegue segue: UIStoryboardSegue, sender: Any?)
}

final class PlayerViewController: UIViewController, PlayerViewControlling {
    @IBOutlet private(set) weak var appVersionLabel: UILabel!
    private weak var delegate: PlayerViewControllerDelegate?

    var viewState: PlayerViewStating? {
        didSet { _ = viewState.map(bind) }
    }
    var scrubberViewController: ScrubberViewControlling {
        return children.first { $0 is ScrubberViewControlling } as! ScrubberViewControlling
    }
    var infoViewController: InfoViewControlling {
        return children.first { $0 is InfoViewController } as! InfoViewControlling
    }
    var controlsViewController: ControlsViewControlling {
        return children.first { $0 is ControlsViewController } as! ControlsViewControlling
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewState.map(bind)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        delegate?.viewController(self, prepareForSegue: segue, sender: sender)
    }

    func setDelegate(_ delegate: PlayerViewControllerDelegate) {
        self.delegate = delegate
    }

    func showSearch() {
        performSegue(withIdentifier: "showSearchViewController", sender: nil)
    }

    // MARK: - private

    private func bind(_ viewState: PlayerViewStating) {
        guard isViewLoaded else { return }
        appVersionLabel.text = viewState.appVersion
    }
}
