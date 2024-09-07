//
//  BookMetaInfoService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import AVFoundation
import Foundation
import MediaPlayer

struct BookMetaInfoService: IBookMetaInfoService {
	func extractAlbumName(from url: URL?) async throws -> String? {
		guard let url else { return nil }
		
		return try await extractStringResource(by: .commonKeyAlbumName, from: url)
	}
	
	func extractTitle(from url: URL?) async throws -> String? {
		guard let url else { return nil }
		
		return try await extractStringResource(by: .commonKeyTitle, from: url)
	}
	
	func extractAuthor(from url: URL?) async throws -> String? {
		guard let url else { return nil }

		return try await extractStringResource(by: .commonKeyArtist, from: url)
	}
	
	func extractArtwork(from url: URL?) async throws -> Data? {
		guard let url else { return nil }

		return try await extractArtwork(from: url)
	}
	
	func extractDuration(from url: URL?) async throws -> TimeInterval {
		guard let url else { return 0 }

		return try await extractDuration(from: url)
	}
}

private extension BookMetaInfoService {
	func extractArtwork(from url: URL) async throws -> Data? {
		let asset = AVAsset(url: url)
		let metadata = try await asset.load(.commonMetadata)
		for item in metadata where item.commonKey == .commonKeyArtwork {
			return try await item.load(.value) as? Data
		}
		return nil
	}
	
//	guard let artworkImage = UIImage(data: data) else {
//		Log.debug("Failed to extract artwork from metadata of \(asset.description)")
//		break
//	}
//	
//	let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { size in
//		return artworkImage
//	}
//	return artwork
	
	func extractStringResource(
		by key: AVMetadataKey,
		from url: URL
	) async throws -> String? {
		let asset = AVAsset(url: url)
		let metadata = try await asset.load(.commonMetadata)
		for item in metadata {
			if item.commonKey == key {
				if let title = try await item.load(.value) as? String {
					return title
				}
			}
		}
		return nil
	}
	
	func extractDuration(from asset: AVAsset) async throws -> TimeInterval {
		try await asset.load(.duration).seconds
	}
}
