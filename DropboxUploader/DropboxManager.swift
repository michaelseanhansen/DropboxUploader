//
//  DropboxManager.swift
//  DropboxUploader
//
//  Created by Michael Hansen on 11/11/14.
//  Copyright (c) 2014 Michael Sean Hansen. All rights reserved.
//

import Foundation

class DropboxManager {
	
	// MARK: - Properties
	
	private let jpgQuality: CGFloat = 0.7
	private class var appKey: String {
		return ""	// APP KEY GOES HERE
	}
	private class var appSecret: String {
		return ""	// APP SECRET GOES HERE
	}
	class var DropboxConnectedNotification: String {
		return "DropboxIsLikeSoTotallyConnected"
	}
	var connected: Bool {
		return DBAccountManager.sharedManager().linkedAccount != nil
	}
	class var hasCredentials: Bool {
		return countElements(appKey) > 0 && countElements(appSecret) > 0
	}
	
	
	// MARK: - Init
	
	init() {
		if DBAccountManager.sharedManager() == nil {
			DBAccountManager.setSharedManager(DBAccountManager(appKey: DropboxManager.appKey, secret: DropboxManager.appSecret))
		}
		
		if connected && DBFilesystem.sharedFilesystem() == nil {
			createSharedFilesystem()
		}
	}
	
	
	// MARK: - Methods
	
	func connect(fromController controller: UIViewController) {
		disconnect()
		DBAccountManager.sharedManager().linkFromController(controller)
	}
	
	func disconnect() {
		if connected {
			DBAccountManager.sharedManager().linkedAccount.unlink()
		}
	}
	
	func openURL(url: NSURL) -> Bool {
		let account = DBAccountManager.sharedManager().handleOpenURL(url)
		if account == nil {
			return false
		} else {
			if DBFilesystem.sharedFilesystem() == nil {
				createSharedFilesystem()
			}
			
			NSNotificationCenter.defaultCenter().postNotificationName(DropboxManager.DropboxConnectedNotification, object: nil)
			return true
		}
	}
	
	private func createSharedFilesystem() {
		if connected {
			let filesystem = DBFilesystem(account: DBAccountManager.sharedManager().linkedAccount)
			DBFilesystem.setSharedFilesystem(filesystem)
		}
	}
	
	func allFiles() -> [DBFileInfo]? {
		if !connected {
			return nil
		}
		
		var error: DBError?
		let files = DBFilesystem.sharedFilesystem().listFolder(DBPath.root(), error: &error)	// this will block if syncing
		if files != nil	{
			return files as [DBFileInfo]?
		} else {
			return nil
		}
	}
	
	func uploadImage(image: UIImage, name: String) -> Bool {
		if !connected {
			return false
		}
		
		var error: DBError?
		let path = DBPath.root().childPath(name)
		let file = DBFilesystem.sharedFilesystem().createFile(path, error: &error)
		if file == nil {
			return false
		}
		
		let imageData = UIImageJPEGRepresentation(image, jpgQuality)
		return file.writeData(imageData, error: &error)
	}
	
	func imageForFileInfo(fileInfo: DBFileInfo) -> UIImage? {
		if !connected {
			return nil
		}
		
		var error: DBError?
		let file = DBFilesystem.sharedFilesystem().openFile(fileInfo.path, error: &error)
		if file == nil {
			return nil
		}
		
		let imageData = file.readData(&error)
		if imageData == nil {
			return nil
		}
		
		let image = UIImage(data: imageData)
		if image == nil {
			return nil
		} else {
			return image
		}
	}
	
	func addObserver(observer: AnyObject, block: DBObserver) {
		if !connected {
			return
		}
		
		DBFilesystem.sharedFilesystem().addObserver(observer, forPathAndChildren: DBPath.root(), block: block)
	}
	
	func removeObserver(observer: AnyObject) {
		if !connected {
			return
		}
		
		DBFilesystem.sharedFilesystem().removeObserver(observer)
	}
}