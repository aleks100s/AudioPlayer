//
//  PlayerStatus.swift
//  AudioPlayer
//
//  Created by Alexander on 08.09.2024.
//

import Foundation

struct PlayerStatus: Equatable {
	let currentTime: TimeInterval
	let duration: TimeInterval
	var isPlaying: Bool
	
	init(
		currentTime: TimeInterval,
		duration: TimeInterval,
		isPlaying: Bool
	) {
		self.currentTime = currentTime
		self.duration = duration
		self.isPlaying = isPlaying
	}
}

