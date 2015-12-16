//
//  Analytics.swift
//  EasyMusic
//
//  Created by Lee Arromba on 04/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation
import Google

class Analytics {
    private(set) static var shared = Analytics()
    private var sessionStartDate: NSDate?
    private var isSetup: Bool = false
    var dryRun: Bool = false
    
    enum Error: ErrorType {
        case Setup
    }
    
    // MARK: - Internal
    
    func setup() throws {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if configureError != nil {
            log("Error configuring Google services: \(configureError)")
            throw Error.Setup
        }
        
        isSetup = true
        
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true
    
        #if DEBUG
            let path = NSBundle.safeMainBundle().pathForResource("GoogleService-Info", ofType: "plist")!
            let data = NSDictionary(contentsOfFile: path)!
            let devId = data["TRACKING_ID_DEV"] as! String

            gai.defaultTracker = gai.trackerWithTrackingId(devId)
            gai.dryRun = dryRun
            gai.logger.logLevel = GAILogLevel.Warning
        #else
            gai.logger.logLevel = GAILogLevel.None
        #endif
    }
    
    func startSession() {
        guard isSetup == true else {
            return
        }
        
        sessionStartDate = NSDate()
    }
    
    func endSession() {
        guard sessionStartDate != nil else {
            return
        }
        
        let currentDate = NSDate()
        let sessionTimeSecs = currentDate.timeIntervalSinceDate(sessionStartDate!)
        let sessionTimeMilliSecs = NSNumber(unsignedInteger: UInt(sessionTimeSecs * 1000.0))
        let item = GAIDictionaryBuilder.createTimingWithCategory("app",
            interval: sessionTimeMilliSecs,
            name: "session",
            label: nil).build() as [NSObject : AnyObject]
        
        send(item)
        sessionStartDate = nil
    }
    
    func sendScreenNameEvent(screenName: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.set(kGAIScreenName, value: screenName)
        let item = GAIDictionaryBuilder.createScreenView().build() as [NSObject : AnyObject]
        
        send(item)
    }
    
    func sendButtonPressEvent(event: String, classId: String) {
        sendEvent(event, action: classId, category: "button_press")
    }
    
    func sendShareEvent(event: String, classId: String) {
        sendEvent(event, action: classId, category: "share")
    }
    
    func sendAlertEvent(event: String, classId: String) {
        sendEvent(event, action: classId, category: "alert")
    }
    
    func sendErrorEvent(error: NSError, classId: String) {
        sendEvent("domain:\(error.domain), code:\(error.code)", action: classId, category: "error")
    }
    
    // MARK: - Private

    private func sendEvent(event: String, action: String, category: String) {
        let item = GAIDictionaryBuilder.createEventWithCategory(category,
            action: action,
            label: event,
            value: nil).build() as [NSObject : AnyObject]
       
        send(item)
    }
    
    private func send(item: [NSObject : AnyObject]) {
        guard isSetup == true else {
            return
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker.send(item)
    }
}

// MARK - Testing

extension Analytics {
    class var __shared: Analytics {
        set { shared = newValue }
        get { return shared }
    }
    var __defaultTracker: GAITracker {
        set { GAI.sharedInstance().defaultTracker = newValue }
        get { return GAI.sharedInstance().defaultTracker }
    }
    var __isSetup: Bool {
        set { isSetup = newValue }
        get { return isSetup }
    }
}