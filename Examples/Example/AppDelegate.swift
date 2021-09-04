//
//  AppDelegate.swift
//  CommonKeyboardExample
//
//  Created by Kaweerut Kanthawong on 8/9/2019.
//  Copyright © 2019 Kaweerut Kanthawong. All rights reserved.
//

import UIKit
import CommonKeyboard

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Just enabled a single line of code
    // Supported UIScrollView or a class that inherited from (e.g., UITableView or UICollectionView)
    //
    // *** This doesn't work with UITableViewController because they've a built-in handler ***
    //
    CommonKeyboard.shared.enabled = true
    
    // uncomment this line to print out the debug logs
    //CommonKeyboard.shared.debug = true
    return true
  }
  
  func applicationWillResignActive(_ application: UIApplication) {
  }
  
  func applicationDidEnterBackground(_ application: UIApplication) {
  }
  
  func applicationWillEnterForeground(_ application: UIApplication) {
  }
  
  func applicationDidBecomeActive(_ application: UIApplication) {
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
  }
}
