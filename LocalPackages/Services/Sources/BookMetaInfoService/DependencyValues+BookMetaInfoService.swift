//
//  DependencyValues+BookMetaInfoService.swift
//
//
//  Created by Alexander on 17.02.2024.
//

import Dependencies

public extension DependencyValues {
	var bookMetaInfoService: BookMetaInfoService {
		get { self[BookMetaInfoService.self] }
		set { self[BookMetaInfoService.self] = newValue }
	}
}
