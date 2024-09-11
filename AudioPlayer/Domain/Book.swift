//
//  Book.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation
import SwiftData
import UIKit

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
	
	var image: UIImage {
		guard let data = orderedChapters.first?.artworkData else {
			return UIImage(resource: .placeholder)
		}
		
		return UIImage(data: data) ?? UIImage(resource: .placeholder)
	}
	
	init(id: UUID = UUID(), title: String, author: String, chapters: [Chapter]) {
		self.id = id
		self.title = title
		self.author = author
		self.chapters = chapters
	}
	
	func finishBook() {
		for chapter in orderedChapters {
			chapter.currentTime = .zero
		}
		currentChapter = nil
		isFinished = true
	}
	
	func resetProgress() {
		for chapter in orderedChapters {
			chapter.isListened = false
		}
		isFinished = false
	}
}
