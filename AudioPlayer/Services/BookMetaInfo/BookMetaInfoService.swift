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
	func extractBookMetadata(from url: URL?) async throws -> BookMetadata? {
		guard let url else { return nil }

		let asset = AVAsset(url: url)
		let albumName = try await extractStringResource(by: .commonKeyAlbumName, from: asset) ?? "-"
		let artist = try await extractStringResource(by: .commonKeyArtist, from: asset) ?? Bundle.main.infoDictionary?["CFBundleName"] as? String ?? "-"
		let metadata = BookMetadata(albumName: albumName, artist: artist)
		return metadata
	}
	
	func extractChapterMetadata(from url: URL?) async throws -> ChapterMetadata? {
		guard let url else { return nil }

		let asset = AVAsset(url: url)
		let title = try await extractStringResource(by: .commonKeyTitle, from: asset) ?? url.lastPathComponent
		let duration = try await asset.load(.duration).seconds
		let data = try await extractArtwork(from: asset)
		let metadata = ChapterMetadata(title: title, duration: duration, artworkData: data)
		return metadata
	}
}

private extension BookMetaInfoService {
	func extractArtwork(from asset: AVAsset) async throws -> Data? {
		let metadata = try await asset.load(.commonMetadata)
		for item in metadata where item.commonKey == .commonKeyArtwork {
			return try await item.load(.value) as? Data
		}
		return nil
	}
	
	func extractStringResource(
		by key: AVMetadataKey,
		from asset: AVAsset
	) async throws -> String? {
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
