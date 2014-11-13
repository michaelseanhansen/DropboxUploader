//
//  AppDelegate.swift
//  DropboxUploader
//
//  Created by Michael Hansen on 11/11/14.
//  Copyright (c) 2014 Michael Sean Hansen. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	// MARK: - Properties
	
	var window: UIWindow?
	
	
	// MARK: - Methods
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		window = UIWindow(frame: UIScreen.mainScreen().bounds)
		window!.makeKeyAndVisible()
		window!.rootViewController = UINavigationController(rootViewController: LaunchViewController())
		window!.frame = UIScreen.mainScreen().bounds
		
		return true
	}
	
	func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
		return DropboxManager().openURL(url)
	}
}

