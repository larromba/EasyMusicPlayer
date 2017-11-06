//
//  ShareManager.swift
//  EasyMusic
//
//  Created by Lee Arromba on 03/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation
import Social

class ShareManager {
    private weak var presenter: UIViewController!
    private var track: Track!
    private var completion: ((Result, String?) -> Void)?
    private var ComposeViewController = SLComposeViewController.self
    private var AlertAction = UIAlertAction.self
    
    enum Result {
        case success
        case cancelledAfterChoice
        case cancelledBeforeChoice
        case error
    }
    
    // MARK: - Internal
    
    func shareTrack(_ track: Track, presenter: UIViewController, sender: UIView, completion: ((Result, String?) -> Void)?) {
        self.presenter = presenter
        self.track = track
        self.completion = completion;
        
        let choices = createShareChoices { (service: String?) -> Void in
            guard service != nil else {
                return
            }
            self.shareViaService(service!)
        }
        if let popoverController = choices.popoverPresentationController {
            popoverController.sourceView = sender
            popoverController.sourceRect = sender.bounds
            popoverController.permittedArrowDirections = .any
        }
        presenter.present(choices, animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private func shareViaService(_ serviceType: String) {
        if ComposeViewController.isAvailable(forServiceType: serviceType) {
            guard let share = ComposeViewController.init(forServiceType: serviceType), let url = URL(string: Constant.Url.AppStoreLink) else {
                self.completion?(.error, serviceType)
                return
            }
            let text = String(format: localized("share format", classId: ShareManager.self),
                track.artist,
                track.title,
                Constant.String.AppName)
            share.setInitialText(text)
            share.add(url)
            share.completionHandler = { (result:SLComposeViewControllerResult) in
                switch result {
                case .done:
                    self.completion?(.success, serviceType)
                    break
                case .cancelled:
                    self.completion?(.cancelledAfterChoice, serviceType)
                    break
                }
                self.track = nil
            }
            presenter.present(share, animated: true, completion: nil)
        } else {
            completion?(.error, serviceType)
            track = nil
        }
    }
    
    private func createShareChoices(completion: ((String?) -> Void)?) -> UIAlertController {
        let msg = UIAlertController(
            title: localized("share sheet title", classId: ShareManager.self),
            message: localized("share sheet desc", classId: ShareManager.self),
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        msg.addAction(AlertAction.withTitle(localized("share option facebook", classId: ShareManager.self),
            style: .default,
            handler: { (action: UIAlertAction) -> Void in
                completion!(SLServiceTypeFacebook)
                msg.dismiss(animated: true, completion: nil)
        }))
        
        msg.addAction(AlertAction.withTitle(localized("share option twitter", classId: ShareManager.self),
            style: .default,
            handler: { (action: UIAlertAction) -> Void in
                completion!(SLServiceTypeTwitter)
                msg.dismiss(animated: true, completion: nil)
        }))
        
        msg.addAction(AlertAction.withTitle(localized("share option cancel", classId: ShareManager.self),
            style: .cancel,
            handler: { (action: UIAlertAction) -> Void in
                completion!(nil)
                msg.dismiss(animated: true, completion: {
                    self.completion?(.cancelledBeforeChoice, nil)
                })
        }))
        
        return msg
    }
}

// MARK: - Testing

extension ShareManager {
    var __ComposeViewController: SLComposeViewController.Type {
        get { return ComposeViewController }
        set { ComposeViewController = newValue }
    }
    var __AlertAction: UIAlertAction.Type {
        get { return AlertAction }
        set { AlertAction = newValue }
    }
}
