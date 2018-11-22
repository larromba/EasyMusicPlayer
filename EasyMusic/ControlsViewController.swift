import UIKit

protocol ControlsViewDelegate: AnyObject {
    func controlsViewController(_ viewController: ControlsViewControlling, pressedPlay play: UIButton)
    func controlsViewController(_ viewController: ControlsViewControlling, pressedStop stop: UIButton)
    func controlsViewController(_ viewController: ControlsViewControlling, pressedPrev prev: UIButton)
    func controlsViewController(_ viewController: ControlsViewControlling, pressedNext next: UIButton)
    func controlsViewController(_ viewController: ControlsViewControlling, pressedShuffle shuffle: UIButton)
    func controlsViewController(_ viewController: ControlsViewControlling, pressedShare share: UIButton)
    func controlsViewController(_ viewController: ControlsViewControlling, pressedRepeat repeat: UIButton)
}

protocol ControlsViewControlling: AnyObject {
    var viewState: ControlsViewState? { get set }
    var shareButton: UIButton! { get }

    func setDelegate(_ delegate: ControlsViewDelegate)
}

@IBDesignable
final class ControlsViewController: UIViewController, ControlsViewControlling {
    @IBOutlet private(set) weak var playButton: PlayButton!
    @IBOutlet private(set) weak var stopButton: UIButton!
    @IBOutlet private(set) weak var prevButton: UIButton!
    @IBOutlet private(set) weak var nextButton: UIButton!
    @IBOutlet private(set) weak var shuffleButton: UIButton!
    @IBOutlet private(set) weak var shareButton: UIButton!
    @IBOutlet private(set) weak var repeatButton: RepeatButton!

    private weak var delegate: ControlsViewDelegate?
    var viewState: ControlsViewState? {
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
        delegate?.controlsViewController(self, pressedPlay: sender)
    }

    @IBAction private func stopButtonPressed(_ sender: UIButton) {
        delegate?.controlsViewController(self, pressedStop: sender)
    }

    @IBAction private func prevButtonPressed(_ sender: UIButton) {
        delegate?.controlsViewController(self, pressedPrev: sender)
    }

    @IBAction private func nextButtonPressed(_ sender: UIButton) {
        delegate?.controlsViewController(self, pressedNext: sender)
    }

    @IBAction private func shuffleButtonPressed(_ sender: UIButton) {
        delegate?.controlsViewController(self, pressedShuffle: sender)
    }

    @IBAction private func shareButtonPressed(_ sender: UIButton) {
        delegate?.controlsViewController(self, pressedShare: sender)
    }

    @IBAction private func repeatButtonPressed(_ sender: UIButton) {
        delegate?.controlsViewController(self, pressedRepeat: sender)
    }

    // MARK: - private

    private func bind(_ viewState: ControlsViewState) {
        playButton.viewState = viewState.playButton
        stopButton.bind(viewState.stopButton)
        repeatButton.viewState = viewState.repeatButton
        prevButton.bind(viewState.prevButton)
        nextButton.bind(viewState.nextButton)
        shareButton.bind(viewState.shareButton)
        shuffleButton.bind(viewState.shuffleButton)
        repeatButton.viewState = viewState.repeatButton
    }
}
