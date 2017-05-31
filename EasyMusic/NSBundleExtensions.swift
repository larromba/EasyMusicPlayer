//
//  NSBundleExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 12/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

extension Bundle {
    class func appName() -> String {
        return Bundle.safeMainBundle().object(forInfoDictionaryKey: Constant.Bundle.BundleDisplayName) as! String
    }
    
    class func appVersion() -> String {
        return "v\(Bundle.safeMainBundle().object(forInfoDictionaryKey: Constant.Bundle.BundleVersion) as? String ?? "?")"
    }
    
    class func bundleIdentifier() -> String {
        return Bundle.safeMainBundle().object(forInfoDictionaryKey: Constant.Bundle.BundleIdentifier) as! String
    }
    
    class func safeMainBundle() -> Bundle {
        return Bundle(identifier: Constant.Bundle.HardCodedMainBundleIdentifier)!
    }
}
