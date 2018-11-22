import Foundation
import Social

enum ShareResult {
    case success
    case cancelledAfterChoice
    case cancelledBeforeChoice
    case error
}

protocol ShareManaging {
    func shareTrack(_ track: Track, presenter: UIViewController, sender: UIView,
                    completion: ((ShareResult, String?) -> Void)?)
}

final class ShareManager: ShareManaging {
    private weak var presenter: UIViewController?
    private var track: Track?
    private var completion: ((ShareResult, String?) -> Void)?
    private let appStoreLink: URL
    //TODO: this
//    private var ComposeViewController = SLComposeViewController.self
//    private var AlertAction = UIAlertAction.self

    init(appStoreLink: URL) {
        self.appStoreLink = appStoreLink
    }

    func shareTrack(_ track: Track, presenter: UIViewController, sender: UIView,
                    completion: ((ShareResult, String?) -> Void)?) {
        self.presenter = presenter
        self.track = track
        self.completion = completion

        let choices = makeShareChoices { (service: String?) -> Void in
            guard let service = service else { return }
            self.shareViaService(service)
        }
        if let popoverController = choices.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
        }
        presenter.present(choices, animated: true, completion: nil)
    }

    // MARK: - Private

    private func makeShareChoices(completion: ((String?) -> Void)?) -> UIAlertController {
        let msg = UIAlertController(
            title: L10n.shareSheetTitle,
            message: L10n.shareSheetDesc,
            preferredStyle: UIAlertControllerStyle.actionSheet)
        //TODO: this
//        msg.addAction(UIAlertAction.withTitle(
//            L10n.shareOptionFacebook,
//            style: .default,
//            handler: { (_: UIAlertAction) -> Void in
//                completion?(SLServiceTypeFacebook)
//                msg.dismiss(animated: true, completion: nil)
//            }
//        ))
//
//        msg.addAction(UIAlertAction.withTitle(
//            L10n.shareOptionTwitter,
//            style: .default,
//            handler: { (_: UIAlertAction) -> Void in
//                completion?(SLServiceTypeTwitter)
//                msg.dismiss(animated: true, completion: nil)
//            }
//        ))
//
//        msg.addAction(UIAlertAction.withTitle(
//            L10n.shareOptionCancel,
//            style: .cancel,
//            handler: { (_: UIAlertAction) -> Void in
//                completion?(nil)
//                msg.dismiss(animated: true, completion: {
//                    self.completion?(.cancelledBeforeChoice, nil)
//                })
//            }
//        ))

        return msg
    }

    private func shareViaService(_ serviceType: String) {
        // TODO: SLComposeViewController
        let isAvailable = SLComposeViewController.isAvailable(forServiceType: serviceType)
        if let presenter = presenter, let track = track, isAvailable {
            guard let share = SLComposeViewController(forServiceType: serviceType) else {
                self.completion?(.error, serviceType)
                return
            }
            let text = L10n.shareFormat(track.artist, track.title, Bundle.appName)
            share.setInitialText(text)
            share.add(appStoreLink)
            share.completionHandler = { (result: SLComposeViewControllerResult) in
                switch result {
                case .done:
                    self.completion?(.success, serviceType)
                case .cancelled:
                    self.completion?(.cancelledAfterChoice, serviceType)
                }
                self.track = nil
            }
            presenter.present(share, animated: true, completion: nil)
        } else {
            completion?(.error, serviceType)
            track = nil
        }
    }
}
