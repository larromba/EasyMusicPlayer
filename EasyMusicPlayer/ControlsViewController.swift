import UIKit

protocol ControlsViewDelegate: AnyObject {
    func viewController(_ viewController: ControlsViewControlling, handleAction action: PlayerAction,
                        forButton button: UIButton)
}

// sourcery: name = ControlsViewController
protocol ControlsViewControlling: Mockable {
    var viewState: ControlsViewStating? { get set }

    func setDelegate(_ delegate: ControlsViewDelegate)
}

@IBDesignable
final class ControlsViewController: UIViewController, ControlsViewControlling {
    @IBOutlet private(set) weak var playButton: PlayButton!
    @IBOutlet private(set) weak var stopButton: UIButton!
    @IBOutlet private(set) weak var prevButton: UIButton!
    @IBOutlet private(set) weak var nextButton: UIButton!
    @IBOutlet private(set) weak var shuffleButton: UIButton!
    @IBOutlet private(set) weak var repeatButton: RepeatButton!
    @IBOutlet private(set) weak var searchButton: UIButton!

    private weak var delegate: ControlsViewDelegate?
    var viewState: ControlsViewStating? {
        didSet { _ = viewState.map(bind) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewState.map(bind)
    }

    func setDelegate(_ delegate: ControlsViewDelegate) {
        self.delegate = delegate
    }

    // MARK: - IBAction

    @IBAction private func playButtonPressed(_ sender: UIButton) {
        delegate?.viewController(self, handleAction: .play, forButton: sender)
    }

    @IBAction private func stopButtonPressed(_ sender: UIButton) {
        delegate?.viewController(self, handleAction: .stop, forButton: sender)
    }

    @IBAction private func prevButtonPressed(_ sender: UIButton) {
        delegate?.viewController(self, handleAction: .prev, forButton: sender)
    }

    @IBAction private func nextButtonPressed(_ sender: UIButton) {
        delegate?.viewController(self, handleAction: .next, forButton: sender)
    }

    @IBAction private func shuffleButtonPressed(_ sender: UIButton) {
        delegate?.viewController(self, handleAction: .shuffle, forButton: sender)
    }

    @IBAction private func repeatButtonPressed(_ sender: UIButton) {
        delegate?.viewController(self, handleAction: .changeRepeatMode, forButton: sender)
    }

    @IBAction private func searchButtonPressed(_ sender: UIButton) {
        delegate?.viewController(self, handleAction: .search, forButton: sender)
    }

    // MARK: - private

    private func bind(_ viewState: ControlsViewStating) {
        playButton.viewState = viewState.playButton
        stopButton.bind(viewState.stopButton)
        repeatButton.viewState = viewState.repeatButton
        prevButton.bind(viewState.prevButton)
        nextButton.bind(viewState.nextButton)
        shuffleButton.bind(viewState.shuffleButton)
        repeatButton.viewState = viewState.repeatButton
        searchButton.bind(viewState.searchButton)
    }
}
