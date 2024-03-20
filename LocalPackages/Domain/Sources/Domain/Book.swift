//
//  Book.swift
//  
//
//  Created by Alexander on 17.02.2024.
//

import UIKit

public struct Book {
	public let id: UUID
	public let title: String
	public let author: String
	public let artwork: UIImage?
	public var chapters: [AudioFile]
	public var currentChapterName: String?
	
	public var progress: Double {
		let allChapters = chapters.count
		let readChapters = chapters.filter(\.isListened).count
		return Double(readChapters) / Double(allChapters)
	}
	
	public init(id: UUID, title: String, author: String, artwork: UIImage?, chapters: [AudioFile]) {
		self.id = id
		self.title = title
		self.author = author
		self.artwork = artwork
		self.chapters = chapters
	}
}

extension Book: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}
}

extension Book: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

extension Book: Identifiable {}
