//
//  NSBundleExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

extension NSBundle {
    class func appName() -> String! {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName") as! String
    }
}