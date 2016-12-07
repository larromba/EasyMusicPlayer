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
    fileprivate(set) static var shared = Analytics()
    fileprivate var sessionStartDate: Date?
    fileprivate var isSetup: Bool = false
    var dryRun: Bool = false
    
    enum AnalyticsError: Error {
        case setup
    }
    
    // MARK: - Internal
    
    func setup() throws {
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        
        if configureError != nil {
            log("Error configuring Google services: \(configureError)")
            throw AnalyticsError.setup
        }
        
        isSetup = true
        
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true
    
        #if DEBUG
            let path = Bundle.safeMainBundle().path(forResource: "GoogleService-Info", ofType: "plist")!
            let data = NSDictionary(contentsOfFile: path)!
            let devId = data["TRACKING_ID_DEV"] as! String

            gai?.defaultTracker = gai?.tracker(withTrackingId: devId)
            gai?.dryRun = dryRun
            gai?.logger.logLevel = GAILogLevel.warning
        #else
            gai?.logger.logLevel = GAILogLevel.none
        #endif
    }
    
    func startSession() {
        guard isSetup == true else {
            return
        }
        
        sessionStartDate = Date()
    }
    
    func endSession() {
        guard sessionStartDate != nil else {
            return
        }
        
        sendTimedAppEvent("session", fromDate: sessionStartDate!, toDate: Date())
        sessionStartDate = nil
    }
    
    func sendScreenNameEvent(_ screenName: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: screenName)
        let item = GAIDictionaryBuilder.createScreenView().build() as NSDictionary as! [AnyHashable: Any]
        
        send(item)
    }
    
    func sendButtonPressEvent(_ event: String, classId: String) {
        sendEvent(event, action: classId, category: "button_press")
    }
    
    func sendShareEvent(_ event: String, classId: String) {
        sendEvent(event, action: classId, category: "share")
    }
    
    func sendAlertEvent(_ event: String, classId: String) {
        sendEvent(event, action: classId, category: "alert")
    }
    
    func sendErrorEvent(_ error: Error, classId: String) {
        let nsError = error as NSError
        sendEvent("domain:\(nsError.domain), code:\(nsError.code)", action: classId, category: "error")
    }
    
    func sendTimedAppEvent(_ event: String, fromDate: Date, toDate: Date) {
        let sessionTimeSecs = toDate.timeIntervalSince(fromDate)
        let sessionTimeMilliSecs = NSNumber(value: UInt(sessionTimeSecs * 1000.0) as UInt)
        let item = GAIDictionaryBuilder.createTiming(withCategory: "app",
            interval: sessionTimeMilliSecs,
            name: event,
            label: nil).build() as NSDictionary as! [AnyHashable: Any]
        
        send(item)
    }
    
    // MARK: - Private
    
    fileprivate func sendTimedEvent(_ event: String, category: String, fromDate: Date, toDate: Date) {
        let sessionTimeSecs = toDate.timeIntervalSince(fromDate)
        let sessionTimeMilliSecs = NSNumber(value: UInt(sessionTimeSecs * 1000.0) as UInt)
        let item = GAIDictionaryBuilder.createTiming(withCategory: category,
            interval: sessionTimeMilliSecs,
            name: event,
            label: nil).build() as NSDictionary as! [AnyHashable: Any]
        
        send(item)
    }
    
    fileprivate func sendEvent(_ event: String, action: String, category: String) {
        let item = GAIDictionaryBuilder.createEvent(withCategory: category,
            action: action,
            label: event,
            value: nil).build() as NSDictionary as! [AnyHashable: Any]
       
        send(item)
    }
    
    fileprivate func send(_ item: [AnyHashable: Any]) {
        guard isSetup == true else {
            return
        }
        
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.send(item)
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
