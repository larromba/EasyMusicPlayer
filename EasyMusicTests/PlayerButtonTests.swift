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
        animationExpectation = expectation(description: "layer.addAnimation(_, _)")

        // mocks
        class MockLayer: CALayer {
            override func add(_ anim: CAAnimation, forKey key: String?) {
                let basicAnim = anim as! CABasicAnimation
                if basicAnim.keyPath == "transform.scale" {
                    animationExpectation!.fulfill()
                }
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
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}
