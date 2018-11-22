import UIKit

extension UIAlertController {
    class func withTitle(_ title: String?, message: String?, buttonTitle: String?) -> UIAlertController {
        return withTitle(title, message: message, buttonTitle: buttonTitle, buttonAction: nil)
    }

    class func withTitle(_ title: String?, message: String?, buttonTitle: String?,
                         buttonAction: (() -> Void)?) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)

        alert.addAction(UIAlertAction.withTitle(
            buttonTitle,
            style: UIAlertActionStyle.default,
            handler: { _ -> Void in
                buttonAction?()
                alert.dismiss(animated: true, completion: nil)
            }
        ))

        return alert
    }
}
