//
//  TrackManagerTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 24/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import Social
@testable import EasyMusic

class ShareManagerTests: XCTestCase {
    private var shareManager: ShareManager?
    
    override func setUp() {
        super.setUp()
        
        shareManager = ShareManager()
    }
    
    override func tearDown() {
        super.tearDown()
        
        shareManager = nil
    }
    
    func testShareOptionsPresented() {
        /**
         expectations
         - share options appear
         */
         
        // mocks
        let mockPresenter = UIViewController()
        UIApplication.sharedApplication().keyWindow?.rootViewController = mockPresenter
        
        let mockTrack = Track(artist: "artist", title: "title", duration: 0.0, artwork: nil, url: NSURL())
        
        // runnable
        shareManager!.shareTrack(mockTrack, presenter: mockPresenter, completion: nil)
        
        // tests
        XCTAssertTrue(mockPresenter.presentedViewController is UIAlertController)
        
        let presentedViewController = mockPresenter.presentedViewController as! UIAlertController
        XCTAssertTrue(presentedViewController.preferredStyle == UIAlertControllerStyle.ActionSheet)
    }
    
    func testShareFacebook() {
        /**
         expectations
         - facebook share opens
         */
        let waitExpectation = expectationWithDescription("wait")
        
        // mocks
        class MockAlertAction: UIAlertAction {
            var mockHandler: (UIAlertAction -> Void)!

            override class func withTitle(title: String?, style: UIAlertActionStyle, handler: (UIAlertAction -> Void)?) -> UIAlertAction {
                let alert = MockAlertAction(title: title, style: style, handler: handler)
                alert.mockHandler = handler
                return alert
            }
        }
        
        class MockComposeViewController: SLComposeViewController {
            override class func isAvailableForServiceType(serviceType: String!) -> Bool { return true }
        }
        
        let mockActionType = MockAlertAction.self
        shareManager!._injectAlertAction(mockActionType)
        
        let mockComposerViewController = MockComposeViewController.self
        shareManager!._injectComposeViewController(mockComposerViewController)
        
        let mockPresenter = UIViewController()
        UIApplication.sharedApplication().keyWindow?.rootViewController = mockPresenter
        
        let mockTrack = Track(artist: "artist", title: "title", duration: 0.0, artwork: nil, url: NSURL())
        
        // runnable
        shareManager!.shareTrack(mockTrack, presenter: mockPresenter, completion: nil)
        
        let presentedViewController = mockPresenter.presentedViewController as! UIAlertController
        let action = presentedViewController.actions[0] as! MockAlertAction
        
        presentedViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
            action.mockHandler(action)

            // tests
            XCTAssertTrue(mockPresenter.presentedViewController is SLComposeViewController)
            
            let presentedComposeViewController = mockPresenter.presentedViewController as! SLComposeViewController
            XCTAssertTrue(presentedComposeViewController.serviceType == SLServiceTypeFacebook)
            
            waitExpectation.fulfill()
        })

        waitForExpectationsWithTimeout(2, handler: { error in XCTAssertNil(error) })
    }
}