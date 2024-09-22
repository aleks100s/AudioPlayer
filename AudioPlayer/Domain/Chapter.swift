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
	@Attribute(.externalStorage, .transformable(by: UIImageTransformer.self))
	private var artworkImage: UIImage
	
	var image: UIImage {
		if Self.imageCache.object(forKey: id as NSUUID) == nil {
			let image = artworkImage
			Self.imageCache.setObject(image, forKey: id as NSUUID)
			return image
		} else {
			return Self.imageCache.object(forKey: id as NSUUID) ?? .placeholder
		}
	}
	
	var artwork: MPMediaItemArtwork? {
		let artworkImage = artworkImage
		let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { size in
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
		self.artworkImage = UIImage(data: artworkData ?? Data()) ?? .placeholder
		self.order = order
		self.isListened = isListened
	}
}
