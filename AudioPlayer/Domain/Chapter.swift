//
//  Chapter.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation
import SwiftData

@Model
final class Chapter {
	let id: UUID
	@Attribute(.spotlight)
	let name: String
	let duration: Double
	let url: URL
	@Attribute(.externalStorage)
	let artworkData: Data?
	var isListened: Bool
	
	init(id: UUID = UUID(), name: String, duration: Double, url: URL, artworkData: Data?, isListened: Bool = false) {
		self.id = id
		self.name = name
		self.duration = duration
		self.url = url
		self.artworkData = artworkData
		self.isListened = isListened
	}
}
