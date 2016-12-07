//
//  ShareManager.swift
//  EasyMusic
//
//  Created by Lee Arromba on 03/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation
import Social

class ShareManager: NSObject {
    fileprivate weak var presenter: UIViewController!
    fileprivate var track: Track!
    fileprivate var completion: ((Result, String?) -> Void)?
    fileprivate var ComposeViewController = SLComposeViewController.self
    fileprivate var AlertAction = UIAlertAction.self
    
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
    
    fileprivate func shareViaService(_ serviceType: String) {
        if ComposeViewController.isAvailable(forServiceType: serviceType) {
            guard let share = ComposeViewController.init(forServiceType: serviceType), let url = URL(string: Constant.Url.AppStoreLink) else {
                self.completion?(Result.error, serviceType)
                return
            }
            let text = String(format: localized("share format"),
                track.artist,
                track.title,
                Constant.String.AppName)
            share.setInitialText(text)
            share.add(url)
            share.completionHandler = { (result:SLComposeViewControllerResult) in
                switch result {
                case .done:
                    self.completion?(Result.success, serviceType)
                    break
                case .cancelled:
                    self.completion?(Result.cancelledAfterChoice, serviceType)
                    break
                }
                self.track = nil
            }
            presenter.present(share, animated: true, completion: nil)
        } else {
            completion?(Result.error, serviceType)
            track = nil
        }
    }
    
    fileprivate func createShareChoices(completion: ((String?) -> Void)?) -> UIAlertController {
        let msg = UIAlertController(
            title: localized("share sheet title"),
            message: localized("share sheet desc"),
            preferredStyle: UIAlertControllerStyle.actionSheet)
        
        msg.addAction(AlertAction.withTitle(localized("share option facebook"),
            style: .default,
            handler: { (action: UIAlertAction) -> Void in
                completion!(SLServiceTypeFacebook)
                msg.dismiss(animated: true, completion: nil)
        }))
        
        msg.addAction(AlertAction.withTitle(localized("share option twitter"),
            style: .default,
            handler: { (action: UIAlertAction) -> Void in
                completion!(SLServiceTypeTwitter)
                msg.dismiss(animated: true, completion: nil)
        }))
        
        msg.addAction(AlertAction.withTitle(localized("share option cancel"),
            style: .cancel,
            handler: { (action: UIAlertAction) -> Void in
                completion!(nil)
                msg.dismiss(animated: true, completion: {
                    self.completion?(Result.cancelledBeforeChoice, nil)
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
