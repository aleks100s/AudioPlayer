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
	
	let id: UUID
	@Attribute(.spotlight)
	let title: String
	@Attribute(.spotlight)
	let author: String
	@Attribute(.externalStorage, .transformable(by: UIImageTransformer.self))
	let artworkImage: UIImage
	var currentChapter: Chapter?
	var progress = Double.zero
	var isFinished = false
	@Relationship(deleteRule: .cascade)
	private var chapters: [Chapter]
	
	var orderedChapters: [Chapter] {
		if Self.cache[id] == nil {
			Self.cache[id] = chapters.sorted(by: { $0.order < $1.order })
		}
		
		return Self.cache[id] ?? []
	}
	
	init(id: UUID = UUID(), title: String, author: String, artworkData: Data?, chapters: [Chapter]) {
		self.id = id
		self.title = title
		self.author = author
		self.artworkImage = UIImage(data: artworkData ?? Data()) ?? .placeholder
		self.chapters = chapters
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
