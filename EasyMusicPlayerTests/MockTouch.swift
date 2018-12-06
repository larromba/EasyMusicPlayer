import UIKit

final class MockTouch: UITouch {
    private let _location: CGPoint

    // swiftlint:disable identifier_name
    init(x: CGFloat = 0, y: CGFloat = 0) {
        _location = CGPoint(x: x, y: y)
        super.init()
    }

    override func location(in view: UIView?) -> CGPoint {
        return _location
    }
}
