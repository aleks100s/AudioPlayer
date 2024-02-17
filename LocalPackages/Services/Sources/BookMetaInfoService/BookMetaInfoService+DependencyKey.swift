//
//  BookMetaInfoService+DependencyKey.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import AVFoundation
import ComposableArchitecture

extension BookMetaInfoService: DependencyKey {
	public static var liveValue: BookMetaInfoService {
		BookMetaInfoService(
			extractTitleFromURL: { url in
				guard let url else { return nil }
				
				return try await AssetMetaInfoExtractor.extractStringResource(by: .commonKeyAlbumName, from: AVAsset(url: url))
			},
			extractAuthorFromURL: { url in
				guard let url else { return nil }

				return try await AssetMetaInfoExtractor.extractStringResource(by: .commonKeyArtist, from: AVAsset(url: url))
			},
			extractArtworkFromURL: { url in
				guard let url else { return nil }

				return try await AssetMetaInfoExtractor.extractArtwork(from: AVAsset(url: url))
			}
		)
	}
	
	public static var previewValue: BookMetaInfoService {
		BookMetaInfoService(
			extractTitleFromURL: { _ in nil },
			extractAuthorFromURL: { _ in nil },
			extractArtworkFromURL: { _ in nil }
		)
	}
}
