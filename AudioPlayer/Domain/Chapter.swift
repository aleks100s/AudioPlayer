//
//  Chapter.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation
import MediaPlayer
import SwiftData

@Model
final class Chapter {
	private static let imageCache = NSCache<NSUUID, UIImage>()
	
	var id: UUID
	@Attribute(.spotlight)
	var name: String
	var duration: Double
	var urlLastPathComponent: String
	var order: Int
	var isListened: Bool
	var currentTime: Double = 0
	@Attribute(.externalStorage)
	private var artworkImage: Data
	
	var image: UIImage {
		if Self.imageCache.object(forKey: id as NSUUID) == nil {
			let image = UIImage(data: artworkImage) ?? .placeholder
			Self.imageCache.setObject(image, forKey: id as NSUUID)
			return image
		} else {
			return Self.imageCache.object(forKey: id as NSUUID) ?? .placeholder
		}
	}
	
	var artwork: MPMediaItemArtwork? {
		let artworkImage = image
		let artwork = MPMediaItemArtwork(boundsSize: image.size) { size in
			return artworkImage
		}
		return artwork
	}
	
	init(
		id: UUID = UUID(),
		name: String,
		duration: Double,
		urlLastPathComponent: String,
		artworkData: Data?,
		order: Int,
		isListened: Bool = false
	) {
		self.id = id
		self.name = name
		self.duration = duration
		self.urlLastPathComponent = urlLastPathComponent
		self.artworkImage = artworkData ?? UIImage.placeholder.pngData() ?? Data()
		self.order = order
		self.isListened = isListened
	}
}
