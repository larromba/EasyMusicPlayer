//
//  GCD.swift
//  EasyMusic
//
//  Created by Lee Arromba on 17/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation

func performAfterDelay(_ delay:Double, closure: @escaping ((Void) -> Void)) {
    DispatchQueue.main.asyncAfter(deadline: .now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
}
