//
//  Book.swift
//  
//
//  Created by Alexander on 17.02.2024.
//

import UIKit

public struct Book {
	public let title: String
	public let author: String
	public let artwork: UIImage?
	public let chapters: [AudioFile]
	
	public init(title: String, author: String, artwork: UIImage?, chapters: [AudioFile]) {
		self.title = title
		self.author = author
		self.artwork = artwork
		self.chapters = chapters
	}
}

extension Book: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		lhs.title == rhs.title && lhs.author == rhs.author
	}
}

extension Book: Identifiable {
	public var id: String {
		title + author
	}
}
