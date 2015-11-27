//
//  NSBundleExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

extension NSBundle {
    public class func appName() -> String! {
        return NSBundle.safeMainBundle().objectForInfoDictionaryKey(Constant.Bundle.BundleDisplayName) as! String
    }
    
    public class func bundleIdentifier() -> String! {
        return NSBundle.safeMainBundle().objectForInfoDictionaryKey(Constant.Bundle.BundleIdentifier) as! String
    }
    
    public class func safeMainBundle() -> NSBundle! {
        return NSBundle(identifier: Constant.Bundle.HardCodedMainBundleIdentifier)
    }
}