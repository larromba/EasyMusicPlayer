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
    var shareManager: ShareManager!
    
    override func setUp() {
        super.setUp()
        
        shareManager = ShareManager()
    }
    
    func testShareOptionsPresented() {
        // mocks
        let mockPresenter = UIViewController()
        UIApplication.sharedApplication().keyWindow?.rootViewController = mockPresenter
        
        let mockTrack = Track(artist: "artist", title: "title", duration: 0.0, artwork: nil, url: NSURL())
        
        // runnable
        shareManager.shareTrack(mockTrack, presenter: mockPresenter)
        
        // tests
        XCTAssertTrue(mockPresenter.presentedViewController is UIAlertController)
        
        let presentedViewController = mockPresenter.presentedViewController as! UIAlertController
        XCTAssertTrue(presentedViewController.preferredStyle == UIAlertControllerStyle.ActionSheet)
    }
    
    func testShareFacebookSuccess() {
        // mocks
        class MockAlertAction: UIAlertAction {
            var mockHandler: (UIAlertAction -> Void)!

            override class func withTitle(title: String?, style: UIAlertActionStyle, handler: (UIAlertAction -> Void)?) -> UIAlertAction! {
                let alert = MockAlertAction(title: title, style: style, handler: handler)
                alert.mockHandler = handler
                return alert
            }
        }
        
        class MockComposeViewController: SLComposeViewController {
            override class func isAvailableForServiceType(serviceType: String!) -> Bool { return true }
        }
        
        let mockActionType = MockAlertAction.self
        shareManager._injectAlertAction(mockActionType)
        
        let mockComposerViewController = MockComposeViewController.self
        shareManager._injectComposeViewController(mockComposerViewController)
        
        let mockPresenter = UIViewController()
        UIApplication.sharedApplication().keyWindow?.rootViewController = mockPresenter
        
        let mockTrack = Track(artist: "artist", title: "title", duration: 0.0, artwork: nil, url: NSURL())
        
        // runnable
        shareManager.shareTrack(mockTrack, presenter: mockPresenter)
        
        let presentedViewController = mockPresenter.presentedViewController as! UIAlertController
        let action = presentedViewController.actions[0] as! MockAlertAction
        action.mockHandler(action)
        
        // tests
        performAfterDelay(1) { () -> (Void) in
            XCTAssertTrue(mockPresenter.presentedViewController is SLComposeViewController)

            let presentedComposeViewController = mockPresenter.presentedViewController as! SLComposeViewController
            XCTAssertTrue(presentedComposeViewController.serviceType == SLServiceTypeFacebook)
        }
    }
    
    func testShareFacebookFail() {
        // mocks
        class MockAlertAction: UIAlertAction {
            var mockHandler: (UIAlertAction -> Void)!
            
            override class func withTitle(title: String?, style: UIAlertActionStyle, handler: (UIAlertAction -> Void)?) -> UIAlertAction! {
                let alert = MockAlertAction(title: title, style: style, handler: handler)
                alert.mockHandler = handler
                return alert
            }
        }
        
        class MockComposeViewController: SLComposeViewController {
            override class func isAvailableForServiceType(serviceType: String!) -> Bool { return false }
        }
        
        let mockActionType = MockAlertAction.self
        shareManager._injectAlertAction(mockActionType)
        
        let mockComposerViewController = MockComposeViewController.self
        shareManager._injectComposeViewController(mockComposerViewController)
        
        let mockPresenter = UIViewController()
        UIApplication.sharedApplication().keyWindow?.rootViewController = mockPresenter
        
        let mockTrack = Track(artist: "artist", title: "title", duration: 0.0, artwork: nil, url: NSURL())
        
        // runnable
        shareManager.shareTrack(mockTrack, presenter: mockPresenter)
        
        let presentedViewController = mockPresenter.presentedViewController as! UIAlertController
        let action = presentedViewController.actions[0] as! MockAlertAction
        action.mockHandler(action)
        
        // tests
        performAfterDelay(1) { () -> (Void) in
            XCTAssertTrue(mockPresenter.presentedViewController is UIAlertController)
        }
    }
}