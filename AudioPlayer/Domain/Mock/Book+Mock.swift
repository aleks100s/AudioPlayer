//
//  Book+Mock.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation

extension Book {
	static func arbitrary(
		id: UUID = UUID(),
		title: String = "Дюна",
		author: String = "Фрэнк Герберт",
		artworkData: Data? = nil,
		chapters: [Chapter] = .arbitrary()
	) -> Book {
		Book(
			id: id,
			title: title,
			author: author,
			artworkData: artworkData,
			chapters: chapters
		)
	}
}
