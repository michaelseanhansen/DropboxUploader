//
//  LaunchViewController.swift
//  DropboxUploader
//
//  Created by Michael Hansen on 11/11/14.
//  Copyright (c) 2014 Michael Sean Hansen. All rights reserved.
//

import UIKit

class LaunchViewController: UIViewController {
	
	// MARK: - Properties
	
	@IBOutlet var launchContainer: UIView!
	@IBOutlet var loadingContainer: UIView!
	@IBOutlet var welcomeContainer: UIView!
	@IBOutlet var retryContainer: UIView!
	
	
	// MARK: - Lifecycle
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.navigationController!.navigationBarHidden = true
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		if !DropboxManager.hasCredentials {
			self.launchContainer.hidden = true
			let alertController = UIAlertController(title: "Dropbox app credentials missing", message: "Please enter a 'key' and 'secret' in 'DropboxManager.swift'.", preferredStyle: .Alert)
			alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
			presentViewController(alertController, animated: true, completion: nil)
			
			return
		}
		
		if !launchContainer.hidden {
			fadeOutLaunchViews()
		}
	}
	
	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	
	// MARK: - Methods
	
	func fadeOutLaunchViews() {
		let dropboxConnected = DropboxManager().connected
		let container = dropboxConnected ? loadingContainer : welcomeContainer
		showContainer(container, completion: {
			if dropboxConnected {
				self.loadDropboxFiles()
			}
		})
	}
	
	@IBAction func connectTapped(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "dropboxDidConnect", name: DropboxManager.DropboxConnectedNotification, object: nil)
		DropboxManager().connect(fromController: self)
	}
	
	func dropboxDidConnect() {
		showContainer(self.loadingContainer, completion: {
			self.loadDropboxFiles()
		})
	}
	
	@IBAction func retryTapped(sender: AnyObject) {
		showContainer(self.loadingContainer, completion: {
			self.loadDropboxFiles()
		})
	}
	
	func loadDropboxFiles() {
		// wait for sync and file load on background thread
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
			let files = DropboxManager().allFiles()
			dispatch_async(dispatch_get_main_queue(), { () -> Void in
				if files == nil {
					self.showContainer(self.retryContainer, completion: nil)
				} else {
					let vc = FileListViewController(files: files!)
					self.navigationController!.setNavigationBarHidden(false, animated: true)
					self.navigationController!.setViewControllers([vc], animated: true)
				}
			})
		})
	}
	
	func showContainer(container: UIView, completion: (() -> Void)?) {
		container.hidden = false
		UIView.animateWithDuration(
			0.5,
			delay: 0.5,
			options: .allZeros,
			animations: {
				
				if container != self.launchContainer {
					self.launchContainer.alpha = 0
				}
				
				if container != self.loadingContainer {
					self.loadingContainer.alpha = 0
				}
				
				if container != self.welcomeContainer {
					self.welcomeContainer.alpha = 0
				}
				
				if container != self.retryContainer {
					self.retryContainer.alpha = 0
				}
				
				container.alpha = 1
				
			},
			completion: { (completed: Bool) in
				self.launchContainer.hidden = container != self.launchContainer
				self.loadingContainer.hidden = container != self.loadingContainer
				self.welcomeContainer.hidden = container != self.welcomeContainer
				self.retryContainer.hidden = container != self.retryContainer
				
				completion?()
			}
		)
	}
}
