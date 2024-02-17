//
//  AssetMetaInfoExtractor.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import AVFoundation
import MediaPlayer
import Shared
import UIKit

enum AssetMetaInfoExtractor {
	static func extractArtwork(from asset: AVAsset) async throws -> MPMediaItemArtwork? {
		let metadata = try await asset.load(.commonMetadata)
		for item in metadata {
			if item.commonKey == .commonKeyArtwork {
				if let data = try await item.load(.value) as? Data {
					guard let artworkImage = UIImage(data: data) else {
						Log.debug("Failed to extract artwork from metadata of \(asset.description)")
						break
					}
					
					let artwork = MPMediaItemArtwork(boundsSize: artworkImage.size) { size in
						return artworkImage
					}
					return artwork
				}
			}
		}
		return nil
	}
	
	static func extractStringResource(
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
}
