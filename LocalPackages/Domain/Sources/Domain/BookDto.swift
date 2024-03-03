//
//  BookDto.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import Foundation

public struct BookDto {
	public let id: UUID
	public let title: String
	public let author: String
	public let files: [String]
	
	public init(id: UUID, title: String, author: String, files: [String]) {
		self.id = id
		self.title = title
		self.author = author
		self.files = files
	}
}

extension BookDto: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

extension BookDto: Codable {
	private enum CodingKeys: CodingKey {
		case id
		case title
		case author
		case files
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = UUID(uuidString: try container.decode(String.self, forKey: .id)) ?? UUID()
		title = try container.decode(String.self, forKey: .title)
		author = try container.decode(String.self, forKey: .author)
		files = try container.decode([String].self, forKey: .files)
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(id.uuidString, forKey: .id)
		try container.encode(title, forKey: .title)
		try container.encode(author, forKey: .author)
		try container.encode(files, forKey: .files)
	}
}
