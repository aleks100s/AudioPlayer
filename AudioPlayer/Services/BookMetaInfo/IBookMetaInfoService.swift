//
//  BookMetaInfoService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation
import MediaPlayer

protocol IBookMetaInfoService {
	func extractBookMetadata(from url: URL?) async throws -> BookMetadata?
	func extractChapterMetadata(from url: URL?) async throws -> ChapterMetadata?
}
