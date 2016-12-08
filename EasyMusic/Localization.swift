//
//  Localization.swift
//  EasyMusic
//
//  Created by Lee Arromba on 08/12/2016.
//  Copyright © 2016 Lee Arromba. All rights reserved.
//

import Foundation

func localized(_ key: String, classId: Any) -> String {
    let string = NSLocalizedString(key, tableName: "\(classId)", bundle: Bundle.main, value: "", comment: "")
    safeAssert(string != key, "missing localization: \(key), in class: \(classId)")
    return string
}
