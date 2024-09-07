//
//  Book.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation
import SwiftData

@Model
final class Book {
	let id: UUID
	let title: String
	let author: String
	let artworkData: Data?
	@Relationship(deleteRule: .cascade)
	var chapters: [Chapter]
	
	init(id: UUID, title: String, author: String, artworkData: Data?, chapters: [Chapter]) {
		self.id = id
		self.title = title
		self.author = author
		self.artworkData = artworkData
		self.chapters = chapters
	}
}
