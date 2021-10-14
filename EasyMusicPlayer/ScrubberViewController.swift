import UIKit

protocol ScrubberViewDelegate: AnyObject {
    func viewController(_ viewController: ScrubberViewControlling, touchesBegan touches: Set<UITouch>,
                        with event: UIEvent?)
    func viewController(_ viewController: ScrubberViewControlling, touchesMoved touches: Set<UITouch>,
                        with event: UIEvent?)
    func viewController(_ viewController: ScrubberViewControlling, touchesEnded touches: Set<UITouch>,
                        with event: UIEvent?)
}

// sourcery: name = ScrubberViewController
protocol ScrubberViewControlling: Mockable {
    var viewState: ScrubberViewStating? { get set }
    // sourcery: value = 0.0
    var viewWidth: CGFloat { get }

    func setDelegate(_ delegate: ScrubberViewDelegate)
    // sourcery: returnValue = CGPoint.zero
    func tapLocation(for touch: UITouch) -> CGPoint
}

@IBDesignable
final class ScrubberViewController: UIViewController, ScrubberViewControlling {
    @IBOutlet private(set) weak var trailingEdgeConstraint: NSLayoutConstraint!
    @IBOutlet private(set) weak var barView: UIView!

    private weak var delegate: ScrubberViewDelegate?
    var viewState: ScrubberViewStating? {
        didSet { _ = viewState.map(bind) }
    }
    var viewWidth: CGFloat {
        return view.bounds.width
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = viewState.map(bind)
    }

    func setDelegate(_ delegate: ScrubberViewDelegate) {
        self.delegate = delegate
    }

    func tapLocation(for touch: UITouch) -> CGPoint {
        return touch.location(in: view)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.viewController(self, touchesBegan: touches, with: event)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.viewController(self, touchesMoved: touches, with: event)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.viewController(self, touchesEnded: touches, with: event)
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
