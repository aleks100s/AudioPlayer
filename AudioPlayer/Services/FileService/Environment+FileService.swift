//
//  Environment+FileService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

private struct FileServiceKey: EnvironmentKey {
	static let defaultValue: FileService = FileService()
}

extension EnvironmentValues {
	var fileService: FileService {
		get { self[FileServiceKey.self] }
		set { self[FileServiceKey.self] = newValue }
	}
}
