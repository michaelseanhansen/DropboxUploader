//
//  ImageViewerController.swift
//  DropboxUploader
//
//  Created by Michael Hansen on 11/12/14.
//  Copyright (c) 2014 Michael Sean Hansen. All rights reserved.
//

import UIKit

class ImageViewerController: UIViewController {
	
    // MARK: - Properties
	
	private var image: UIImage!
	@IBOutlet var imageView: UIImageView!
	
	
	// MARK: - Init
	
	convenience init(image: UIImage) {
		self.init()
		self.image = image
	}
	
	
	// MARK: - Lifecycle
	
	override func viewDidLoad() {
		self.imageView.image = self.image
	}
	
	
	// MARK: - Methods
	
	@IBAction func buttonTapped(sender: AnyObject) {
		let hideNavBar = !self.navigationController!.navigationBarHidden
		self.navigationController?.setNavigationBarHidden(hideNavBar, animated: true)
		UIApplication.sharedApplication().setStatusBarHidden(hideNavBar, withAnimation: UIStatusBarAnimation.Slide)
		UIView.animateWithDuration(0.3, animations: {
			self.view.backgroundColor = hideNavBar ? UIColor.blackColor() : UIColor.whiteColor()
		})
	}
}
