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
	static var cache = [UUID: [Chapter]]()
	
	var id: UUID
	@Attribute(.spotlight)
	var title: String
	@Attribute(.spotlight)
	var author: String
	@Attribute(.externalStorage, .transformable(by: UIImageTransformer.self))
	var artworkImage: UIImage
	var currentChapter: Chapter?
	var progress = Double.zero
	var isFinished = false
	@Relationship(deleteRule: .cascade)
	private var chapters: [Chapter]
	
	var orderedChapters: [Chapter] {
		Self.cache[id] ?? []
	}
	
	init(id: UUID = UUID(), title: String, author: String, artworkData: Data?, chapters: [Chapter]) {
		self.id = id
		self.title = title
		self.author = author
		self.artworkImage = UIImage(data: artworkData ?? Data()) ?? .placeholder
		self.chapters = chapters
	}
	
	func prepareOrderedChapters() {
		Self.cache[id] = chapters.sorted(by: { $0.order < $1.order })
	}
	
	func finishBook() {
		for chapter in orderedChapters {
			chapter.currentTime = .zero
		}
		currentChapter = nil
		isFinished = true
		progress = 1
	}
	
	func trackProgress() {
		progress = Double(chapters.filter(\.isListened).count) / Double(chapters.count)
	}
	
	func resetProgress() {
		for chapter in orderedChapters {
			chapter.isListened = false
		}
		isFinished = false
	}
}
