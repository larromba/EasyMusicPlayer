import UIKit

/// @mockable
@MainActor
protocol URLSharable {
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey : Any],
        completionHandler completion: (@MainActor @Sendable (Bool) -> Void)?
    )
}
extension UIApplication: URLSharable {}
