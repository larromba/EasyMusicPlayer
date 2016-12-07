//
//  ShuffleButtonTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 16/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import UIKit
@testable import EasyMusic

private var animationExpectation: XCTestExpectation?

class ShuffleButtonTests: XCTestCase {
    override func tearDown() {
        animationExpectation = nil
        
        super.tearDown()
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
                if basicAnim.keyPath == "transform.rotation.z" {
                    animationExpectation!.fulfill()
                }
            }
        }
        
        class MockShuffleButton: ShuffleButton {
            override var layer: CALayer {
                return MockLayer()
            }
        }
        
        let mockShuffleButton = MockShuffleButton()
        
        // runnable
        mockShuffleButton.touchUpInside()
        
        // tests
        waitForExpectations(timeout: 1, handler: { error in XCTAssertNil(error) })
    }
}
