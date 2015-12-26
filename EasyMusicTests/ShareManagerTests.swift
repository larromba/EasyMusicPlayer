//
//  TrackManagerTests.swift
//  EasyMusic
//
//  Created by Lee Arromba on 24/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import XCTest
import Social
import MediaPlayer
@testable import EasyMusic

private let mockArtist = "artist"
private let mockTitle = "title"
private let mockDuration = 9.0
private let mockImage = UIImage()
private let mockArtwork = MPMediaItemArtwork(image: mockImage)
private let mockAssetUrl = NSURL(fileURLWithPath: Constant.Path.DummyAudio)

class ShareManagerTests: XCTestCase {
    private var shareManager: ShareManager?
    
    class MockMediaItem: MPMediaItem {
        override var artist: String { return mockArtist }
        override var title: String { return mockTitle }
        override var playbackDuration: NSTimeInterval { return mockDuration }
        override var artwork: MPMediaItemArtwork { return mockArtwork }
        override var assetURL: NSURL { return mockAssetUrl }
    }
    
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
        UIApplication.sharedApplication().keyWindow!.rootViewController = mockPresenter
        
        let mockTrack = Track(mediaItem: MockMediaItem())
        
        // runnable
        shareManager!.shareTrack(mockTrack, presenter: mockPresenter, sender: mockPresenter.view, completion: nil)
        
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
        shareManager!.__AlertAction = mockActionType
        
        let mockComposerViewController = MockComposeViewController.self
        shareManager!.__ComposeViewController = mockComposerViewController
        
        let mockPresenter = UIViewController()
        UIApplication.sharedApplication().keyWindow!.rootViewController = mockPresenter
        
        let mockTrack = Track(mediaItem: MockMediaItem())
        
        // runnable
        shareManager!.shareTrack(mockTrack, presenter: mockPresenter, sender: mockPresenter.view, completion: nil)
        
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