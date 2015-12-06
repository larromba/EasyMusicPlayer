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
    static let shared = Analytics()
    
    // MARK: - Internal
    
    func setup() {
        // Configure tracker from GoogleService-Info.plist.
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        safeAssert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai.trackUncaughtExceptions = true  // report uncaught exceptions
        
        #if DEBUG
            gai.dryRun = true
            gai.logger.logLevel = GAILogLevel.Verbose
        #else
            gai.logger.logLevel = GAILogLevel.None
        #endif
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
    
    // MARK: - Private
    
    private func sendEvent(event: String, action: String, category: String) {
        let tracker = GAI.sharedInstance().defaultTracker
        let item = GAIDictionaryBuilder.createEventWithCategory(category,
            action: action,
            label: event,
            value: nil).build() as [NSObject : AnyObject]
        tracker.send(item)
    }
}