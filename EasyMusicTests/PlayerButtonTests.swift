//
//  PlayerButtonTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import UIKit
@testable import EasyMusic

private var animationExpectation: XCTestExpectation?

class PlayerButtonTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        
        animationExpectation = nil
    }
    
    func testAnimation() {
        /**
         expectations
         - animation is added
         */
        animationExpectation = expectationWithDescription("layer.addAnimation(_, _)")

        // mocks
        class MockLayer: CALayer {
            override func addAnimation(anim: CAAnimation, forKey key: String?) {
                animationExpectation?.fulfill()
            }
        }
        
        class MockPlayerButton: PlayerButton {
            override var layer: CALayer {
                return MockLayer()
            }
        }
        
        let mockPlayerButton = MockPlayerButton()
        
        // runnable
        mockPlayerButton.touchUpInside()
        
        // tests
        waitForExpectationsWithTimeout(1, handler: { error in XCTAssertNil(error) })
    }
}