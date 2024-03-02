//
//  BookMetaInfoService.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import Domain
import MediaPlayer
import UIKit

public struct BookMetaInfoService {
	public let extractTitleFromURL: (URL?) async throws -> String?
	public let extractAuthorFromURL: (URL?) async throws -> String?
	public let extractArtworkFromURL: (URL?) async throws -> MPMediaItemArtwork?
	public let extractDurationFromURL: (URL?) async throws -> TimeInterval
	
	public init(
		extractTitleFromURL: @escaping (URL?) async throws -> String?,
		extractAuthorFromURL: @escaping (URL?) async throws -> String?,
		extractArtworkFromURL: @escaping (URL?) async throws -> MPMediaItemArtwork?,
		extractDurationFromURL: @escaping (URL?) async throws -> TimeInterval
	) {
		self.extractTitleFromURL = extractTitleFromURL
		self.extractAuthorFromURL = extractAuthorFromURL
		self.extractArtworkFromURL = extractArtworkFromURL
		self.extractDurationFromURL = extractDurationFromURL
	}
}
