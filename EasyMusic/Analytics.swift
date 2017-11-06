//
//  Analytics.swift
//  EasyLife
//
//  Created by Lee Arromba on 04/12/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import Foundation
import FirebaseAnalytics

class Analytics {
    private(set) static var shared = Analytics()
    private var sessionStartDate: Date?
    private var isSetup: Bool
    private var AnalyticsType: FirebaseAnalytics.Analytics.Type
    
    enum AnalyticsError: Error {
        case setup
    }
    
    init() {
        sessionStartDate = nil
        isSetup = false
        AnalyticsType = FirebaseAnalytics.Analytics.self
    }
    
    // TESTING
    
    init(type: FirebaseAnalytics.Analytics.Type, isSetup: Bool, sessionStartDate: Date) {
        self.sessionStartDate = sessionStartDate
        self.isSetup = isSetup
        self.AnalyticsType = type
    }
    
    // MARK: - Internal
    
    func setup() throws {
        let path = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
        guard let options = FirebaseOptions(contentsOfFile: path) else {
            throw AnalyticsError.setup
        }
        FirebaseApp.configure(options: options)
        isSetup = true
    }
    
    func startSession() {
        guard isSetup else {
            return
        }
        
        sessionStartDate = Date()
        logEvent(withName: AnalyticsEventAppOpen, parameters: nil)
    }
    
    func endSession() {
        guard sessionStartDate != nil else {
            return
        }
        
        sendTimedAppEvent("app_closed", fromDate: sessionStartDate!, toDate: Date())
        sessionStartDate = nil
    }
    
    func sendScreenNameEvent(_ classId: Any) {
        logEvent(withName: "\(classId)", parameters: nil)
    }
    
    func sendEvent(_ event: String, classId: Any) {
        logEvent(withName: "\(classId)", parameters: [
            "event" : event
            ])
    }
    
    func sendButtonPressEvent(_ event: String, classId: Any) {
        logEvent(withName: "\(classId)", parameters: [
            "button_press" : event
            ])
    }
    
    func sendShareEvent(_ event: String, classId: Any) {
        logEvent(withName: "\(classId)", parameters: [
            "share" : event
            ])
    }
    
    func sendAlertEvent(_ event: String, classId: Any) {
        logEvent(withName: "\(classId)", parameters: [
            "alert" : event
            ])
    }
    
    func sendErrorEvent(_ error: Error, classId: Any) {
        let nsError = error as NSError
        logEvent(withName: "\(classId)", parameters: [
            "error-domain" : nsError.domain,
            "error-code" : nsError.code,
            "error-description": nsError.localizedDescription
            ])
    }
    
    func sendTimedAppEvent(_ event: String, fromDate: Date, toDate: Date) {
        let sessionTimeSecs = toDate.timeIntervalSince(fromDate)
        let sessionTimeMilliSecs = sessionTimeSecs * 1000.0
        logEvent(withName: event, parameters: [
            "time" : sessionTimeMilliSecs
            ])
    }
    
    // MARK: - Private
    
    private func logEvent(withName name: String, parameters: [String: Any]?) {
        guard isSetup else {
            return
        }
        
        AnalyticsType.logEvent(name, parameters: parameters)
    }
}

// MARK - Testing

extension Analytics {
    class var __shared: Analytics {
        set { shared = newValue }
        get { return shared }
    }
    var __AnalyticsType: FirebaseAnalytics.Analytics.Type {
        set { AnalyticsType = newValue }
        get { return AnalyticsType }
    }
    var __isSetup: Bool {
        set { isSetup = newValue }
        get { return isSetup }
    }
}
