//
//  BookMetaInfoService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import Foundation
import MediaPlayer

protocol IBookMetaInfoService {
	func extractAlbumName(from url: URL?) async throws -> String?
	func extractTitle(from url: URL?) async throws -> String?
	func extractAuthor(from url: URL?) async throws -> String?
	func extractArtwork(from url: URL?) async throws -> Data?
	func extractDuration(from url: URL?) async throws -> TimeInterval
}
