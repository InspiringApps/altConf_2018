//  altConf
//  Created by Erwin Mazariegos on 5/25/18 using Swift 4.0.
//  Copyright © 2018 Erwin. All rights reserved.

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		LogFunc()
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {	LogFunc()	}
	func applicationDidEnterBackground(_ application: UIApplication) {	LogFunc()	}
	func applicationWillEnterForeground(_ application: UIApplication) {	LogFunc()	}
	func applicationDidBecomeActive(_ application: UIApplication) {		LogFunc()	}
	func applicationWillTerminate(_ application: UIApplication) {		LogFunc()	}

}

