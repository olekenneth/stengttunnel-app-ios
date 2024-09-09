//
//  Stengt_tunnelApp.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

import GoogleMobileAds


class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      GADMobileAds.sharedInstance().start(completionHandler: nil)
#if DEBUG
      GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "dd2a8297212c345481b88d737efcb859", "39047ab61ba93265f45268e643febead" ]
#endif
      
    return true
  }
}

@main
struct Stengt_tunnelApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            RoadList()
        }
    }
}
