//
//  AppDelegate.swift
//  CommonKeyboardExample
//
//  Created by Kevin's Macbook Pro on 14/3/2566 BE.
//

import UIKit
import CommonKeyboard

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // just enable this single line of code below
    // supported UIScrollView including inherited classes (e.g., UITableView or UICollectionView)
    //
    // *** This doesn't work with UITableViewController because they've built-in handler ***
    //
    CommonKeyboard.shared.enabled = true
    
    // uncomment this line to print the debug logs
    //CommonKeyboard.shared.debug = true
    
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
  
}
