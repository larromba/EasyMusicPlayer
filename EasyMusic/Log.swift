//
//  Log.swift
//  EasyMusic
//
//  Created by Lee Arromba on 15/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

public func safeAssert(condition: Bool, _ msg: String) {
    if condition == false {
        log(msg)
    }
}

public func log(msg: String) {
    print(msg)
}