//
//  XCTestExtension.swift
//  EasyMusic
//
//  Created by Lee Arromba on 24/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest

func XCTAssertMethodOrderCorrect(_ methodOrder: [Int]) {
    var orderCorrect = true
    for (index, element) in methodOrder.enumerated() {
        if element != index {
            orderCorrect = false
            break
        }
    }
    XCTAssert(orderCorrect)
}
