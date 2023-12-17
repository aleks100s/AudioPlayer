//
//  DependencyValues+FileService.swift
//  Player
//
//  Created by Alexander on 16.12.2023.
//

import Dependencies

public extension DependencyValues {
	var fileService: FileService {
		get { self[FileService.self] }
		set { self[FileService.self] = newValue }
	}
}
