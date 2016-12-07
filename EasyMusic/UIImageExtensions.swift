//
//  UIImageExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit

extension UIImage {
    public class func safeImage(named name: String) -> UIImage {
        let image = UIImage(named: name, in: Bundle.safeMainBundle(), compatibleWith: nil)
        safeAssert(image != nil, "missing image with name: \(name)")
        return image!
    }
}
