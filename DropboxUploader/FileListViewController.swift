//
//  FileListViewController.swift
//  DropboxUploader
//
//  Created by Michael Hansen on 11/12/14.
//  Copyright (c) 2014 Michael Sean Hansen. All rights reserved.
//

import UIKit

class FileListViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
	
	// MARK: - Properties
	
	private var files: [DBFileInfo]!
	private let reuseIdentifier = "A Super Cool Reuse Identifier"
	
	
	// MARK: - Init
	
	convenience init(files: [DBFileInfo]) {
		self.init(style: UITableViewStyle.Plain)
		self.title = "Files"
		tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
		self.files = files
		self.navigationItem.hidesBackButton = true		// fixes a bug where the back button appears breifly
		self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Camera, target: self, action: "cameraButtonTapped")
		
		DropboxManager().addObserver(self, block: {
			self.files = DropboxManager().allFiles()
			self.tableView.reloadData()
		})
	}
	
	
	// MARK: - Lifecycle
	
	deinit {
		DropboxManager().removeObserver(self)
	}
	
	
    // MARK: - Table stuff
	
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
	
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return files.count == 0 ? 1 : files.count
    }
	
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as UITableViewCell
		cell.textLabel.text = files.count == 0 ? "Empty. (Add something!)" : files[indexPath.row].path.name()
        return cell
    }
	
	override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		tableView.deselectRowAtIndexPath(indexPath, animated: true)
		if self.files.count > 0 {
			let fileInfo = self.files[indexPath.row]
			dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
				let image = DropboxManager().imageForFileInfo(fileInfo)
				dispatch_async(dispatch_get_main_queue(), { () -> Void in
					if image == nil {
						self.showErrorAlert("Image loading error", message: "Check your internet connection and make sure this file is an image, then try again.")
					} else {
						let vc = ImageViewerController(image: image!)
						vc.title = fileInfo.path.name()
						self.navigationController?.pushViewController(vc, animated: true)
					}
				})
			})
		}
	}
	
	
	// MARK: - Image picker delegate
	
	func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
		dismissViewControllerAnimated(true, nil)
		var image: UIImage!
		image = info[UIImagePickerControllerEditedImage] as UIImage
		if image == nil {
			image = info[UIImagePickerControllerOriginalImage] as UIImage
		}
		
		if image != nil {
			uploadImage(image)
		}
	}
	
	
	// MARK: - Methods
	
	func cameraButtonTapped() {
		let cameraAvailable = UIImagePickerController.isSourceTypeAvailable(.Camera)
		let libraryAvailable = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
		
		if cameraAvailable && libraryAvailable {
			let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
			alertController.addAction(UIAlertAction(
				title: "Take photo",
				style: .Default,
				handler: { (action: UIAlertAction!) -> Void in
					self.showImagePicker(.Camera)
				}
			))
			
			alertController.addAction(UIAlertAction(
				title: "Choose existing photo",
				style: .Default,
				handler: { (action: UIAlertAction!) -> Void in
					self.showImagePicker(.PhotoLibrary)
				}
			))
			
			alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
			presentViewController(alertController, animated: true, completion: nil)
		} else if cameraAvailable {
			self.showImagePicker(.Camera)
		} else if libraryAvailable {
			self.showImagePicker(.PhotoLibrary)
		}
	}
	
	private func showImagePicker(sourceType: UIImagePickerControllerSourceType) {
		let vc = UIImagePickerController()
		vc.sourceType = sourceType
		vc.allowsEditing = true
		vc.delegate = self
		presentViewController(vc, animated: true, completion: nil)
	}
	
	private func uploadImage(image: UIImage) {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateStyle = .LongStyle
		dateFormatter.timeStyle = .LongStyle
		let imageName = "Photo - " + dateFormatter.stringFromDate(NSDate()) + ".jpg"
		
		let dman = DropboxManager()
		let success = dman.uploadImage(image, name: imageName)
		if !success {
			showErrorAlert("There was an error saving your photo.", message: "Please try again.")
		}
	}
	
	private func showErrorAlert(title: String?, message: String?) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
		alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
		presentViewController(alertController, animated: true, completion: nil)
	}
}