import UIKit

protocol ScrubberViewDelegate: AnyObject {
    func scrubberViewController(_ viewController: ScrubberViewControlling,
                                touchesBegan touches: Set<UITouch>, with event: UIEvent?)
    func scrubberViewController(_ viewController: ScrubberViewControlling,
                                touchesMoved touches: Set<UITouch>, with event: UIEvent?)
    func scrubberViewController(_ viewController: ScrubberViewControlling,
                                touchesEnded touches: Set<UITouch>, with event: UIEvent?)
}

// sourcery: name = ScrubberViewController
protocol ScrubberViewControlling: AnyObject, Mockable {
    var viewState: ScrubberViewStating? { get set }
    var view: UIView! { get }
    var barView: UIView! { get }

    func setDelegate(_ delegate: ScrubberViewDelegate)
}

@IBDesignable
final class ScrubberViewController: UIViewController, ScrubberViewControlling {
    @IBOutlet private(set) weak var trailingEdgeConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var barView: UIView!

    private weak var delegate: ScrubberViewDelegate?
    var viewState: ScrubberViewStating? {
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
        delegate?.scrubberViewController(self, touchesBegan: touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.scrubberViewController(self, touchesMoved: touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.scrubberViewController(self, touchesEnded: touches, with: event)
    }

    // MARK: - private

    private func bind(_ viewState: ScrubberViewStating) {
        guard isViewLoaded else { return }
        view.isUserInteractionEnabled = viewState.isUserInteractionEnabled
        barView.alpha = viewState.barAlpha
        trailingEdgeConstraint.constant = (view.bounds.width - viewState.barWidth)
        view.layoutIfNeeded()
    }
}
