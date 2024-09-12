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
	let id: UUID
	@Attribute(.spotlight)
	let name: String
	let duration: Double
	let urlLastPathComponent: String
	@Attribute(.externalStorage, .transformable(by: UIImageTransformer.self))
	let artworkImage: UIImage
	let order: Int
	var isListened: Bool
	var currentTime: Double = 0
	
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
