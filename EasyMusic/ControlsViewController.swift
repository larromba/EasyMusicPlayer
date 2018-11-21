import UIKit

protocol ControlsViewDelegate: AnyObject {
    func controlsPressedPlay(_ viewController: ControlsViewControlling)
    func controlsPressedStop(_ viewController: ControlsViewControlling)
    func controlsPressedPrev(_ viewController: ControlsViewControlling)
    func controlsPressedNext(_ viewController: ControlsViewControlling)
    func controlsPressedShuffle(_ viewController: ControlsViewControlling)
    func controlsPressedShare(_ viewController: ControlsViewControlling)
    func controlsPressedRepeat(_ viewController: ControlsViewControlling)
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
        sender.pulse() // TODO: move these up?
        delegate?.controlsPressedPlay(self)
    }

    @IBAction private func stopButtonPressed(_ sender: UIButton) {
        sender.pulse()
        delegate?.controlsPressedStop(self)
    }

    @IBAction private func prevButtonPressed(_ sender: UIButton) {
        sender.pulse()
        delegate?.controlsPressedPrev(self)
    }

    @IBAction private func nextButtonPressed(_ sender: UIButton) {
        sender.pulse()
        delegate?.controlsPressedNext(self)
    }

    @IBAction private func shuffleButtonPressed(_ sender: UIButton) {
        sender.pulse()
        sender.spin()
        delegate?.controlsPressedShuffle(self)
    }

    @IBAction private func shareButtonPressed(_ sender: UIButton) {
        sender.pulse()
        delegate?.controlsPressedShare(self)
    }

    @IBAction private func repeatButtonPressed(_ sender: UIButton) {
        sender.pulse()
        delegate?.controlsPressedRepeat(self)
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
