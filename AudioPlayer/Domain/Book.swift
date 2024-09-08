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
	@Relationship(deleteRule: .cascade)
	private var chapters: [Chapter]
	
	var orderedChapters: [Chapter] {
		chapters.sorted(by: { $0.order > $1.order })
	}
	
	public var progress: Double {
		let allChapters = chapters.count
		let readChapters = chapters.filter(\.isListened).count
		return Double(readChapters) / Double(allChapters)
	}
	
	init(id: UUID = UUID(), title: String, author: String, chapters: [Chapter]) {
		self.id = id
		self.title = title
		self.author = author
		self.chapters = chapters
	}
}
