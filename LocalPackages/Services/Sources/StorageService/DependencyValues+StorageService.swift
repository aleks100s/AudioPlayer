//
//  DependencyValues+StorageService.swift
//
//
//  Created by Alexander on 05.01.2024.
//

import Dependencies

public extension DependencyValues {
	var storageService: StorageService {
		get { self[StorageService.self] }
		set { self[StorageService.self] = newValue }
	}
}
