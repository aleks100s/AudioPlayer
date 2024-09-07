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
	@Attribute(.spotlight)
	let title: String
	@Attribute(.spotlight)
	let author: String
	@Attribute(.externalStorage)
	let artworkData: Data?
	@Relationship(deleteRule: .cascade)
	var chapters: [Chapter]
	
	public var progress: Double {
		let allChapters = chapters.count
		let readChapters = chapters.filter(\.isListened).count
		return Double(readChapters) / Double(allChapters)
	}
	
	init(id: UUID, title: String, author: String, artworkData: Data?, chapters: [Chapter]) {
		self.id = id
		self.title = title
		self.author = author
		self.artworkData = artworkData
		self.chapters = chapters
	}
}
