//
//  GCD.swift
//  EasyMusic
//
//  Created by Lee Arromba on 17/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

public func performAfterDelay(delay:Double, closure: (Void -> Void)!) {
    dispatch_after(
        dispatch_time(
            DISPATCH_TIME_NOW,
            Int64(delay * Double(NSEC_PER_SEC))
        ),
        dispatch_get_main_queue(), closure)
}