//
//  UIAlertControllerExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIAlertController {
    public class func createAlertWithTitle(_ title: String?, message: String?, buttonTitle: String?) -> UIAlertController {
        return createAlertWithTitle(title, message: message, buttonTitle: buttonTitle, buttonAction: nil)
    }
    
    public class func createAlertWithTitle(_ title: String?, message: String?, buttonTitle: String?, buttonAction: ((Void) -> Void)?) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addAction(UIAlertAction.withTitle(buttonTitle,
            style: UIAlertActionStyle.default,
            handler: { (action) -> Void in
                buttonAction?()
                alert.dismiss(animated: true, completion: nil)
        }))
        
        return alert
    }
}
