//
//  Environment+PlayerService.swift
//  AudioPlayer
//
//  Created by Alexander on 08.09.2024.
//

import SwiftUI

private struct PlayerServiceKey: EnvironmentKey {
	static let defaultValue: PlayerService = PlayerService()
}

extension EnvironmentValues {
	var playerService: PlayerService {
		get { self[PlayerServiceKey.self] }
		set { self[PlayerServiceKey.self] = newValue }
	}
}

