//
//  AppDelegate.swift
//  EasyMusic
//
//  Created by Lee Arromba on 01/11/2015.
//  Copyright © 2015 Lee Arromba. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
            log("\nDEBUG BUILD\n")
        #endif
        
        Fabric.with([Crashlytics.self])
        
        do {
            try Analytics.shared.setup()
        } catch _ {
            log("Analytics setup failed")
        }
        Analytics.shared.startSession()
        
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        Analytics.shared.endSession()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        Analytics.shared.startSession()
    }
}
