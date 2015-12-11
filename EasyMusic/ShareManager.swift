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
    private weak var presenter: UIViewController!
    private weak var track: Track!
    private var completion: ((Result, String?) -> Void)?
    private var ComposeViewController = SLComposeViewController.self
    private var AlertAction = UIAlertAction.self
    
    enum Result {
        case Success
        case CancelledAfterChoice
        case CancelledBeforeChoice
        case Error
    }
    
    // MARK: - internal
    
    func shareTrack(track: Track, presenter: UIViewController, completion: ((Result, String?) -> Void)?) {
        self.presenter = presenter
        self.track = track
        self.completion = completion;
        
        let choices = createShareChoices { (service: String?) -> Void in
            if service != nil {
                self.shareViaService(service!)
            }
        }
        self.presenter.presentViewController(choices, animated: true, completion: nil)
    }
    
    // MARK: - private
    
    private func shareViaService(serviceType: String) {
        if ComposeViewController.isAvailableForServiceType(serviceType) {
            let share = ComposeViewController.init(forServiceType: serviceType)
            let text = String(format: localized("share format"),
                track.artist,
                track.title,
                NSBundle.appName())
            share.setInitialText(text)
            share.completionHandler = { (result:SLComposeViewControllerResult) in
                switch result {
                case .Done:
                    self.completion?(Result.Success, serviceType)
                    break
                case .Cancelled:
                    self.completion?(Result.CancelledAfterChoice, serviceType)
                    break
                }
            }
            presenter.presentViewController(share, animated: true, completion: nil)
        } else {
            self.completion?(Result.Error, serviceType)
        }
    }
    
    private func createShareChoices(completion completion: ((String?) -> Void)?) -> UIAlertController {
        let msg = UIAlertController(
            title: localized("share sheet title"),
            message: localized("share sheet desc"),
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        msg.addAction(AlertAction.withTitle(localized("share option facebook"),
            style: .Default,
            handler: { (action: UIAlertAction) -> Void in
                completion!(SLServiceTypeFacebook)
                msg.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        msg.addAction(AlertAction.withTitle(localized("share option twitter"),
            style: .Default,
            handler: { (action: UIAlertAction) -> Void in
                completion!(SLServiceTypeTwitter)
                msg.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        msg.addAction(AlertAction.withTitle(localized("share option cancel"),
            style: .Cancel,
            handler: { (action: UIAlertAction) -> Void in
                completion!(nil)
                msg.dismissViewControllerAnimated(true, completion: {
                    self.completion?(Result.CancelledBeforeChoice, nil)
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