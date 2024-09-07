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
	let name: String
	let url: URL
	var isListened: Bool
	
	init(id: UUID = UUID(), name: String, url: URL, isListened: Bool) {
		self.id = id
		self.name = name
		self.url = url
		self.isListened = isListened
	}
}
