//
//  AppDelegate.swift
//  MoneyFlow
//
//  Created by Никита Гончаров on 01/09/2019.
//  Copyright © 2019 Никита Гончаров. All rights reserved.
//

import UIKit
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    private var authDidChangeHandle: AuthStateDidChangeListenerHandle?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let isFirstLaunch = !GlobalConstants.isThisNotFirstLaunch
        if isFirstLaunch {
            let defaults = UserDefaults()
            defaults.set(true, forKey: GlobalConstants.DefaultsKeys.isNotfirstLaunch)
            defaults.set(true, forKey: GlobalConstants.DefaultsKeys.securityEnabling)
            defaults.set(true, forKey: GlobalConstants.DefaultsKeys.isFirstLoadFromCloud)
            print("isFirstLoad = true")
        }
        
        if let user = Auth.auth().currentUser, user.isEmailVerified {
            instantiateViewController(withIdentifier: Constants.startVCStoryboardID)
        } else {
            instantiateViewController(withIdentifier: Constants.greetingVCStoryboardID)
        }
        
        authDidChangeHandle = Auth.auth().addStateDidChangeListener { [unowned self] (auth, user) in
            if user == nil || !(user?.isEmailVerified ?? false) {
                UserDefaults().set(true, forKey: GlobalConstants.DefaultsKeys.isFirstLoadFromCloud)
                print("isFirstLoad = true")
                self.instantiateViewController(withIdentifier: Constants.greetingVCStoryboardID)
            }
            print("Auth did change its state. Current user is \(user?.email ?? "none")")
        }
        
        return true
    }
    
    private func instantiateViewController(withIdentifier identifier: String) {
        let mainStoryboardIpad = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: identifier) as UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewController
        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    override init() {
        super.init()
        FirebaseApp.configure()
    }

}

private extension AppDelegate {
    struct Constants {
        static let startVCStoryboardID = "startVC"
        static let greetingVCStoryboardID = "greetingVC"
    }
}

