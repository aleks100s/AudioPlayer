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
	@Attribute(.externalStorage)
	let artworkData: Data?
	let order: Int
	var isListened: Bool
	
	var artwork: MPMediaItemArtwork? {
		guard let data = artworkData, let artworkImage = UIImage(data: data) else {
			Log.debug("Failed to extract artwork from metadata of \(name)")
			return nil
		}
		
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
		self.artworkData = artworkData
		self.order = order
		self.isListened = isListened
	}
}
