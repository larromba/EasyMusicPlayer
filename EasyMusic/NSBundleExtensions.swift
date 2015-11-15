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
        return NSBundle.mainBundle().objectForInfoDictionaryKey(Constants.BundleKeys.BundleDisplayName) as! String
    }
    
    class func bundleIdentifier() -> String! {
        return NSBundle.mainBundle().objectForInfoDictionaryKey(Constants.BundleKeys.BundleIdentifier) as! String
    }
    
    class func safeMainBundle() -> NSBundle! {
        return NSBundle(identifier: Constants.Strings.MainBundleIdentifier)
    }
}