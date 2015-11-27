//
//  UIAlertActionExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 27/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIAlertAction {
    public class func withTitle(title: String?, style: UIAlertActionStyle, handler: (UIAlertAction -> Void)?) -> UIAlertAction! {
        return UIAlertAction(title: title, style: style, handler: handler)
    }
}