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
		title: String = "Дюна",
		author: String = "Фрэнк Герберт",
		artwork: UIImage? = UIImage(),
		chapters: [AudioFile] = []
	) -> Book {
		Book(
			title: title,
			author: author,
			artwork: artwork ?? .init(resource: .dune),
			chapters: chapters
		)
	}
}
