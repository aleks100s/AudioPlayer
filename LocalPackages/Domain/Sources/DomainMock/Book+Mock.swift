//
//  Book+Mock.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import Domain
import UIKit

public extension Book {
	static func mock(
		id: UUID = UUID(),
		title: String = "Дюна",
		author: String = "Фрэнк Герберт",
		artwork: UIImage? = nil,
		chapters: [AudioFile] = []
	) -> Book {
		Book(
			id: id,
			title: title,
			author: author,
			artwork: artwork,
			chapters: chapters
		)
	}
}
