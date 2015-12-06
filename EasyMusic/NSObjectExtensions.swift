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
        let className = NSStringFromClass(self.dynamicType)
        let components = className.componentsSeparatedByString(".")
        
        if components.count > 0 {
            return components.last!
        }
        
        return className
    }
    
    public func localized(key: String) -> String {
        let string = NSLocalizedString(key, tableName: self.className(), bundle: NSBundle.mainBundle(), value: "", comment: "")
        safeAssert(string != key, "missing localization: \(key)")
        return string
    }
    
    public func safeSelector(string: String) -> Selector {
        safeAssert(self.respondsToSelector(Selector(string)), "missing method: \(string)")
        return Selector(string)
    }
}