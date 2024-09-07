//
//  Environment+BookMetaInfoService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

private struct BookMetaInfoServiceKey: EnvironmentKey {
	static let defaultValue: BookMetaInfoService = BookMetaInfoService()
}

extension EnvironmentValues {
	var metaInfoService: BookMetaInfoService {
		get { self[BookMetaInfoServiceKey.self] }
		set { self[BookMetaInfoServiceKey.self] = newValue }
	}
}
