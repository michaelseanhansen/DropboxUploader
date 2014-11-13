//
//  UIViewExtension.swift
//  DropboxUploader
//
//  Created by Michael Hansen on 11/11/14.
//  Copyright (c) 2014 Michael Sean Hansen. All rights reserved.
//

import Foundation

extension UIView {
	
	var cornerRadius: CGFloat {
		set {
			layer.cornerRadius = newValue
		}
		get {
			return layer.cornerRadius
		}
	}
	
	var borderColor: UIColor {
		set {
			layer.borderColor = newValue.CGColor
		}
		get {
			return UIColor(CGColor: layer.borderColor)
		}
	}
	
	var borderWidth: CGFloat {
		set {
			layer.borderWidth = newValue
		}
		get {
			return layer.borderWidth
		}
	}
	
}
