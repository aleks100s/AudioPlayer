//
//  UIImageTransformer.swift
//  AudioPlayer
//
//  Created by Alexander on 12.09.2024.
//

import UIKit

final class UIImageTransformer: ValueTransformer {
	override class func allowsReverseTransformation() -> Bool {
		true
	}
	
	override class func transformedValueClass() -> AnyClass {
		UIImage.self
	}
	
	override func transformedValue(_ value: Any?) -> Any? {
		guard let image = value as? UIImage else { return nil }
		
		return image.pngData()
	}
	
	override func reverseTransformedValue(_ value: Any?) -> Any? {
		guard let data = value as? Data else { return nil }
		
		return UIImage(data: data) ?? UIImage(resource: .placeholder)
	}
}
