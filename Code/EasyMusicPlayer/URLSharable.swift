import UIKit

/// @mockable
protocol URLSharable {
    func open(
        _ url: URL,
        options: [UIApplication.OpenExternalURLOptionsKey : Any],
        completionHandler completion: ((Bool) -> Void)?
    )
}
extension UIApplication: URLSharable {}
