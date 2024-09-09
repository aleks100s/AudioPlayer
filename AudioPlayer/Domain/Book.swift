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
	var currentChapter: Chapter?
	var isFinished = false
	@Relationship(deleteRule: .cascade)
	private var chapters: [Chapter]
	
	var orderedChapters: [Chapter] {
		chapters.sorted(by: { $0.order < $1.order })
	}
	
	var progress: Double {
		guard !isFinished else { return 1 }
		
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
	
	func resetBookProgress() {
		for chapter in orderedChapters {
			chapter.currentTime = .zero
			chapter.isListened = false
		}
		currentChapter = nil
		isFinished = true
	}
}
