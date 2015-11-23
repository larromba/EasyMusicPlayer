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
    private(set) weak var presenter: UIViewController!
    private(set) var track: Track!
    
    // MARK: - internal
    
    func shareTrack(track: Track, presenter: UIViewController) {
        self.presenter = presenter
        self.track = track
        
        let choices = createShareChoices { (service) -> Void in
            if service != nil {
                self.shareViaService(service!)
            }
        }
        self.presenter.presentViewController(choices, animated: true, completion: nil)
    }
    
    // MARK: - private
    
    private func shareViaService(serviceType: String) {
        if SLComposeViewController.isAvailableForServiceType(serviceType) {
            let share = SLComposeViewController(forServiceType: serviceType)
            let text = String(format: localized("share format"),
                track.artist,
                track.title,
                NSBundle.appName())
            share.setInitialText(text)
            presenter.presentViewController(share, animated: true, completion: nil)
        } else {
            let alert = UIAlertController.createAlertWithTitle(localized("accounts error title"),
                message: localized("accounts error msg"),
                buttonTitle: localized("accounts error button"))
            presenter.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func createShareChoices(completion completion: ((String?) -> Void)?) -> UIAlertController! {
        let msg = UIAlertController(
            title: localized("share sheet title"),
            message: localized("share sheet desc"),
            preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        msg.addAction(UIAlertAction(
            title: localized("share option facebook"),
            style: UIAlertActionStyle.Default,
            handler: { (action) -> Void in
                completion!(SLServiceTypeFacebook)
                msg.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        msg.addAction(UIAlertAction(
            title: localized("share option twitter"),
            style: UIAlertActionStyle.Default,
            handler: { (action) -> Void in
                completion!(SLServiceTypeTwitter)
                msg.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        msg.addAction(UIAlertAction(
            title: localized("share option cancel"),
            style: UIAlertActionStyle.Cancel,
            handler: { (action) -> Void in
                completion!(nil)
                msg.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        return msg
    }
}