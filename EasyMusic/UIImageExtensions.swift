//
//  UIImageExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIImage {
    class func safeImage(named name: String) -> UIImage! {
        let image = UIImage(named: name, inBundle: NSBundle.safeMainBundle(), compatibleWithTraitCollection: nil)
        safeAssert(image != nil, String("missing image %@", name))
        return image
    }
}