//
//  NSObjectExtensions.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

extension NSObject {
    public func className() -> String {
        let className = NSStringFromClass(type(of: self))
        let components = className.components(separatedBy: ".")
        
        if components.count > 0 {
            return components.last!
        }
        
        return className
    }
    
    public func localized(_ key: String) -> String {
        let string = NSLocalizedString(key, tableName: self.className(), bundle: Bundle.main, value: "", comment: "")
        safeAssert(string != key, "missing localization: \(key)")
        return string
    }
    
    public func safeSelector(_ string: String) -> Selector {
        safeAssert(self.responds(to: Selector(string)), "missing method: \(string)")
        return Selector(string)
    }
}
