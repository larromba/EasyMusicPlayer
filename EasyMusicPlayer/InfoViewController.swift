import UIKit

// sourcery: name = InfoViewController
protocol InfoViewControlling: AnyObject, Mockable {
    var viewState: InfoViewStating? { get set }
}

@IBDesignable
final class InfoViewController: UIViewController, InfoViewControlling {
    @IBOutlet private(set) weak var artistLabel: UILabel!
    @IBOutlet private(set) weak var trackLabel: UILabel!
    @IBOutlet private(set) weak var trackPositionLabel: UILabel!
    @IBOutlet private(set) weak var timeLabel: UILabel!
    @IBOutlet private(set) weak var artworkImageView: UIImageView!

    var viewState: InfoViewStating? {
        didSet { _ = viewState.map(bind) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewState.map(bind)
    }

    // MARK: - private

    private func bind(_ viewState: InfoViewStating) {
        guard isViewLoaded else { return }
        artistLabel.text = viewState.artist
        trackLabel.text = viewState.track
        trackPositionLabel.text = viewState.trackPosition
        timeLabel.text = viewState.time
        artworkImageView.image = viewState.artwork
    }
}
