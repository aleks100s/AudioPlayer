//
//  IFileService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation

protocol IFileService {
	func saveBookFiles(_ files: [URL], id: UUID) throws -> [URL]
	func deleteBookFiles(_ book: Book) throws
}
