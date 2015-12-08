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
    
    func sendErrorEvent(error: NSError, classId: String) {
        sendEvent("domain:\(error.domain), code:\(error.code)", action: classId, category: "error")
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

// MARK - Testing
extension Analytics {
    class func _injectShared(shared: Analytics) {
        self.shared = shared
    }
}