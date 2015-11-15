//
//  UIAlertControllerExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIAlertController {
    class func createAlertWithTitle(title: String?, message: String?, buttonTitle: String?) -> UIAlertController! {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(
            title: buttonTitle,
            style: UIAlertActionStyle.Default,
            handler: { (action) -> Void in
                alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        return alert
    }
}