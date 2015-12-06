//
//  UIAlertControllerExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIAlertController {
    public class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?) -> UIAlertController {
        return createAlertWithTitle(title, message: message, buttonTitle: buttonTitle, buttonAction: nil)
    }
    
    public class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?, buttonAction: (Void -> Void)?) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction.withTitle(buttonTitle,
            style: UIAlertActionStyle.Default,
            handler: { (action) -> Void in
                buttonAction?()
                alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        return alert
    }
}