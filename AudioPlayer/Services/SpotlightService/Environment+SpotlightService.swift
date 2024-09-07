//
//  Environment+SpotlightService.swift
//  AudioPlayer
//
//  Created by Alexander on 07.09.2024.
//

import SwiftUI

private struct SpotlightServiceKey: EnvironmentKey {
	static let defaultValue: SpotlightService = SpotlightService()
}

extension EnvironmentValues {
	var spotlightService: SpotlightService {
		get { self[SpotlightServiceKey.self] }
		set { self[SpotlightServiceKey.self] = newValue }
	}
}
