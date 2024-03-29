//
//  AppDelegate.swift
//  example
//
//  Created by Hoang Nguyen on 10/9/18.
//  Copyright © 2018 Hoang Nguyen. All rights reserved.
//

import UIKit
import MozoSDK

@UIApplicationMain
class AppDelegate: BaseApplication {

    var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		MozoSDK.configure(application: self, network: .DevNet)
		return true
	}
}

