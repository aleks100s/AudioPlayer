//
//  DependencyValues+AudioService.swift
//
//
//  Created by Alexander on 24.12.2023.
//

import Dependencies

public extension DependencyValues {
	var audioService: AudioService {
		get { self[AudioServiceImpl.self] }
		set { self[AudioServiceImpl.self] = newValue }
	}
}
