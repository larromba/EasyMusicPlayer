import UIKit

protocol ScrubberViewDelegate: AnyObject {
    func scrubber(_ scrubber: ScrubberViewControlling, touchesBegan touches: Set<UITouch>, with event: UIEvent?)
    func scrubber(_ scrubber: ScrubberViewControlling, touchesMoved touches: Set<UITouch>, with event: UIEvent?)
    func scrubber(_ scrubber: ScrubberViewControlling, touchesEnded touches: Set<UITouch>, with event: UIEvent?)
}

protocol ScrubberViewControlling: AnyObject {
    var viewState: ScrubberViewState? { get set }
    var view: UIView! { get }
    var barView: UIView! { get }

    func setDelegate(_ delegate: ScrubberViewDelegate)
}

@IBDesignable
final class ScrubberViewController: UIViewController, ScrubberViewControlling {
    @IBOutlet private(set) weak var trailingEdgeConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var barView: UIView!

    private weak var delegate: ScrubberViewDelegate?
    var viewState: ScrubberViewState? {
        didSet { _ = viewState.map(bind) }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewState.map(bind)
    }

    func setDelegate(_ delegate: ScrubberViewDelegate) {
        self.delegate = delegate
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.scrubber(self, touchesBegan: touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.scrubber(self, touchesMoved: touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.scrubber(self, touchesEnded: touches, with: event)
    }

    // MARK: - private

    private func bind(_ viewState: ScrubberViewState) {
        guard isViewLoaded else { return }
        view.isUserInteractionEnabled = viewState.isUserInteractionEnabled
        barView.alpha = viewState.barAlpha
        trailingEdgeConstraint.constant = (view.bounds.width - viewState.barWidth)
        view.layoutIfNeeded()
    }
}
