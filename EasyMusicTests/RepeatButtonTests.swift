//
//  RepeatButtonTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 10/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest

@testable import EasyMusic

class RepeatButtonTests: XCTestCase {
    private var repeatButton: RepeatButton?

    override func setUp() {
        super.setUp()

        repeatButton = RepeatButton()
    }

    override func tearDown() {
        repeatButton = nil

        super.tearDown()
    }

    func testButtonState() {
        /**
         expectations
         - button state is correct
         */

         // mocks
        let expected = RepeatButton.State.all

        // runnable
        repeatButton!.setButtonState(expected)

        // tests
        XCTAssertEqual(repeatButton!.buttonState, expected)
    }

    func testPlayButtonImage() {
        /**
         expectations
         - background image changes
         */

         // mocks
        repeatButton!.setBackgroundImage(nil, for: UIControlState.normal)

        // runnable
        repeatButton!.setButtonState(RepeatButton.State.all)

        // tests
        XCTAssertNotNil(repeatButton!.backgroundImage(for: UIControlState.normal))
    }
}
