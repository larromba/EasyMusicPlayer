//
//  NSBundleExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

extension Bundle {
    public class func appName() -> String {
        return Bundle.safeMainBundle().object(forInfoDictionaryKey: Constant.Bundle.BundleDisplayName) as! String
    }
    
    public class func bundleIdentifier() -> String {
        return Bundle.safeMainBundle().object(forInfoDictionaryKey: Constant.Bundle.BundleIdentifier) as! String
    }
    
    public class func safeMainBundle() -> Bundle {
        return Bundle(identifier: Constant.Bundle.HardCodedMainBundleIdentifier)!
    }
}
